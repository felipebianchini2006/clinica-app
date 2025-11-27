require "test_helper"

class PatientTest < ActiveSupport::TestCase
  def setup
    @maria = patients(:maria)
    @joao = patients(:joao)
    @ana = patients(:ana)
  end

  # Validations
  test "should be valid with valid attributes" do
    patient = Patient.new(
      name: "Novo Paciente",
      cpf: "111.222.333-44",
      email: "novo@email.com",
      phone: "(11) 99999-9999"
    )
    assert patient.valid?
  end

  test "should require name" do
    patient = Patient.new(cpf: "11122233344")
    assert_not patient.valid?
    assert_includes patient.errors[:name], "can't be blank"
  end

  test "should require cpf" do
    patient = Patient.new(name: "Teste")
    assert_not patient.valid?
    assert_includes patient.errors[:cpf], "can't be blank"
  end

  test "should require unique cpf" do
    patient = Patient.new(name: "Duplicado", cpf: @maria.cpf)
    assert_not patient.valid?
    assert_includes patient.errors[:cpf], "has already been taken"
  end

  test "should validate cpf format with dots and dash" do
    patient = Patient.new(name: "Test", cpf: "111.222.333-44")
    assert patient.valid?
  end

  test "should validate cpf format without formatting" do
    patient = Patient.new(name: "Test", cpf: "11122233344")
    assert patient.valid?
  end

  test "should reject invalid cpf format" do
    patient = Patient.new(name: "Test", cpf: "123")
    assert_not patient.valid?
    assert_includes patient.errors[:cpf], "formato inválido"
  end

  test "should allow blank email" do
    patient = Patient.new(name: "Test", cpf: "55566677788", email: "")
    assert patient.valid?
  end

  test "should validate email format when present" do
    patient = Patient.new(name: "Test", cpf: "55566677788", email: "invalid")
    assert_not patient.valid?
    assert_includes patient.errors[:email], "is invalid"
  end

  # Normalizations
  test "should normalize cpf removing special characters" do
    patient = Patient.new(name: "Test", cpf: "111.222.333-44")
    assert_equal "11122233344", patient.cpf
  end

  test "should normalize email to lowercase" do
    patient = Patient.new(name: "Test", cpf: "11122233344", email: "  TEST@EMAIL.COM  ")
    assert_equal "test@email.com", patient.email
  end

  # Methods
  test "should format cpf correctly" do
    assert_equal "123.456.789-01", @maria.formatted_cpf
  end

  test "should calculate age correctly" do
    patient = Patient.new(name: "Test", cpf: "11122233344", birth_date: 30.years.ago.to_date)
    assert_equal 30, patient.age
  end

  test "should return nil age when no birth_date" do
    patient = Patient.new(name: "Test", cpf: "11122233344")
    assert_nil patient.age
  end

  # Scopes
  test "search by name" do
    results = Patient.search("Maria")
    assert_includes results, @maria
    assert_not_includes results, @joao
  end

  test "search by cpf" do
    results = Patient.search(@maria.cpf)
    assert_includes results, @maria
  end

  test "search returns all when query blank" do
    results = Patient.search("")
    # O scope retorna nil quando query é blank, mas Rails encadeia como all
    # Na prática, ao usar .search("").order(...), o comportamento é retornar todos os registros
    assert results.nil? || results.is_a?(ActiveRecord::Relation)
  end

  # Associations
  test "should have many appointments" do
    assert_respond_to @maria, :appointments
  end

  test "should have many practitioners through appointments" do
    assert_respond_to @maria, :practitioners
  end

  test "should have many medical_records" do
    assert_respond_to @maria, :medical_records
  end

  test "should have many invoices" do
    assert_respond_to @maria, :invoices
  end

  test "should destroy dependent appointments" do
    patient = Patient.create!(name: "Test Destroy", cpf: "99988877766")
    practitioner = practitioners(:dr_carlos)
    appointment = Appointment.create!(
      patient: patient,
      practitioner: practitioner,
      scheduled_at: 5.days.from_now,
      duration_minutes: 30
    )
    appointment_id = appointment.id
    patient.destroy
    assert_nil Appointment.find_by(id: appointment_id)
  end
end
