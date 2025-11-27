class Practitioner < ApplicationRecord
  belongs_to :user, optional: true
  has_many :appointments, dependent: :destroy
  has_many :patients, through: :appointments
  has_many :medical_records, dependent: :nullify

  validates :name, presence: true
  validates :specialty, presence: true
  validates :crm, presence: true, uniqueness: true

  scope :active, -> { joins(:user).where(users: { role: :practitioner }) }
  scope :search, ->(query) {
    where("name ILIKE :q OR specialty ILIKE :q OR crm ILIKE :q", q: "%#{query}%") if query.present?
  }
end
