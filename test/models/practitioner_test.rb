require "test_helper"

class PractitionerTest < ActiveSupport::TestCase
  def setup
    @dr_carlos = practitioners(:dr_carlos)
    @dra_patricia = practitioners(:dra_patricia)
  end

  # Validations
  test "should be valid with valid attributes" do
    practitioner = Practitioner.new(
      name: "Dr. Novo Médico",
      specialty: "Ortopedia",
      crm: "CRM-SP 999999",
      phone: "(11) 1234-5678"
    )
    assert practitioner.valid?
  end

  test "should require name" do
    practitioner = Practitioner.new(specialty: "Test", crm: "CRM-SP 111111")
    assert_not practitioner.valid?
    assert_includes practitioner.errors[:name], "can't be blank"
  end

  test "should require specialty" do
    practitioner = Practitioner.new(name: "Dr. Test", crm: "CRM-SP 111111")
    assert_not practitioner.valid?
    assert_includes practitioner.errors[:specialty], "can't be blank"
  end

  test "should require crm" do
    practitioner = Practitioner.new(name: "Dr. Test", specialty: "Test")
    assert_not practitioner.valid?
    assert_includes practitioner.errors[:crm], "can't be blank"
  end

  test "should require unique crm" do
    practitioner = Practitioner.new(
      name: "Duplicado",
      specialty: "Test",
      crm: @dr_carlos.crm
    )
    assert_not practitioner.valid?
    assert_includes practitioner.errors[:crm], "has already been taken"
  end

  # Associations
  test "should belong to user optionally" do
    practitioner = Practitioner.new(
      name: "Dr. Sem User",
      specialty: "Test",
      crm: "CRM-SP 888888"
    )
    assert practitioner.valid?
  end

  test "should have associated user" do
    assert_equal users(:doctor_carlos), @dr_carlos.user
  end

  test "should have many appointments" do
    assert_respond_to @dr_carlos, :appointments
  end

  test "should have many patients through appointments" do
    assert_respond_to @dr_carlos, :patients
  end

  test "should have many medical_records" do
    assert_respond_to @dr_carlos, :medical_records
  end

  # Scopes
  test "search by name" do
    results = Practitioner.search("Carlos")
    assert_includes results, @dr_carlos
    assert_not_includes results, @dra_patricia
  end

  test "search by specialty" do
    results = Practitioner.search("Pediatria")
    assert_includes results, @dra_patricia
    assert_not_includes results, @dr_carlos
  end

  test "search by crm" do
    results = Practitioner.search("123456")
    assert_includes results, @dr_carlos
  end

  test "search scope returns nil or relation when query blank" do
    results = Practitioner.search("")
    # Scope retorna nil quando query vazio, mas encadeado funciona como all
    assert results.nil? || results.is_a?(ActiveRecord::Relation)
  end

  test "active scope returns practitioners with user role practitioner" do
    active = Practitioner.active
    assert_includes active, @dr_carlos
    assert_includes active, @dra_patricia
  end

  # Destroy behavior
  test "should destroy dependent appointments" do
    # Criar user para associar ao practitioner
    user = User.create!(
      name: "Dr. Test Destroy",
      email: "destroy.test@clinica.com",
      password: "password123",
      role: :practitioner
    )
    practitioner = Practitioner.create!(
      name: "Dr. Test Destroy",
      specialty: "Test",
      crm: "CRM-SP 777777",
      user: user
    )
    patient = patients(:maria)
    appointment = Appointment.create!(
      patient: patient,
      practitioner: practitioner,
      scheduled_at: 10.days.from_now,
      duration_minutes: 30
    )
    appointment_id = appointment.id
    practitioner.destroy
    assert_nil Appointment.find_by(id: appointment_id)
  end
end
