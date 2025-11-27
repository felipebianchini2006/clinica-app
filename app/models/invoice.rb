class Invoice < ApplicationRecord
  belongs_to :patient
  belongs_to :appointment, optional: true

  enum :status, {
    pending: 0,
    paid: 1,
    overdue: 2,
    cancelled: 3
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true

  scope :pending, -> { where(status: :pending) }
  scope :paid, -> { where(status: :paid) }
  scope :overdue, -> { pending.where("due_date < ?", Date.current) }
  scope :for_period, ->(start_date, end_date) {
    where(due_date: start_date..end_date) if start_date && end_date
  }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) if patient_id.present? }

  def mark_as_paid!
    update!(status: :paid, paid_at: Time.current)
  end

  def overdue?
    pending? && due_date < Date.current
  end
end
