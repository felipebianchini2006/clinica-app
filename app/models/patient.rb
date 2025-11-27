class Patient < ApplicationRecord
  has_many :appointments, dependent: :destroy
  has_many :practitioners, through: :appointments
  has_many :medical_records, dependent: :destroy
  has_many :invoices, dependent: :destroy

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true,
                  format: { with: /\A\d{3}\.?\d{3}\.?\d{3}-?\d{2}\z/, message: "formato inválido" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  normalizes :cpf, with: ->(cpf) { cpf.gsub(/[^\d]/, "") }
  normalizes :email, with: ->(email) { email.strip.downcase }

  scope :search, ->(query) {
    where("name ILIKE :q OR cpf ILIKE :q", q: "%#{query}%") if query.present?
  }

  def formatted_cpf
    cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, "\\1.\\2.\\3-\\4")
  end

  def age
    return nil unless birth_date
    ((Date.current - birth_date) / 365.25).floor
  end
end
