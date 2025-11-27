class MedicalRecord < ApplicationRecord
  belongs_to :patient
  belongs_to :practitioner
  belongs_to :appointment, optional: true

  has_many_attached :attachments

  validates :diagnosis, presence: true

  scope :for_patient, ->(patient_id) { where(patient_id: patient_id).order(created_at: :desc) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :search, ->(query) {
    where("diagnosis ILIKE :q OR treatment ILIKE :q OR notes ILIKE :q", q: "%#{query}%") if query.present?
  }
end
