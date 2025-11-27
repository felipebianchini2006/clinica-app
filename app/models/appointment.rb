class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :practitioner
  has_one :medical_record, dependent: :nullify
  has_one :invoice, dependent: :nullify

  enum :status, {
    scheduled: 0,
    confirmed: 1,
    in_progress: 2,
    completed: 3,
    cancelled: 4,
    no_show: 5
  }

  validates :scheduled_at, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validate :scheduled_at_in_future, on: :create
  validate :no_overlapping_appointments, on: [ :create, :update ]

  scope :today, -> { where(scheduled_at: Date.current.all_day) }
  scope :upcoming, -> { where("scheduled_at >= ?", Time.current).order(:scheduled_at) }
  scope :past, -> { where("scheduled_at < ?", Time.current).order(scheduled_at: :desc) }
  scope :for_practitioner, ->(practitioner_id) { where(practitioner_id: practitioner_id) if practitioner_id.present? }
  scope :for_date_range, ->(start_date, end_date) {
    where(scheduled_at: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date
  }

  def end_time
    scheduled_at + duration_minutes.minutes
  end

  private

  def scheduled_at_in_future
    if scheduled_at.present? && scheduled_at < Time.current
      errors.add(:scheduled_at, "deve ser no futuro")
    end
  end

  def no_overlapping_appointments
    return unless scheduled_at.present? && practitioner_id.present?

    overlapping = Appointment
      .where(practitioner_id: practitioner_id)
      .where.not(id: id)
      .where.not(status: [ :cancelled, :no_show ])
      .where("scheduled_at < ? AND scheduled_at + (duration_minutes || ' minutes')::interval > ?", end_time, scheduled_at)

    if overlapping.exists?
      errors.add(:scheduled_at, "conflita com outro agendamento")
    end
  end
end
