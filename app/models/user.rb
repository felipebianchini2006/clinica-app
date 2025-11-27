class User < ApplicationRecord
  has_secure_password

  has_one :practitioner, dependent: :destroy

  enum :role, { receptionist: 0, practitioner: 1, admin: 2 }

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true

  normalizes :email, with: ->(email) { email.strip.downcase }
end
