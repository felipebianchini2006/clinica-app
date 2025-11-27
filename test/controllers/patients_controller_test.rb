require "test_helper"

class PatientsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    @patient = patients(:maria)
    @joao = patients(:joao)
    # Login as admin for all tests
    post session_path, params: { email: @admin.email, password: "password123" }
  end

  # Authentication
  test "should redirect to login when not authenticated" do
    delete session_path
    get patients_path
    assert_redirected_to new_session_path
  end

  # GET /patients
  test "should get index" do
    get patients_path
    assert_response :success
    assert_select "h1", text: /Pacientes/i
  end

  test "should search patients by name" do
    get patients_path, params: { search: "Maria" }
    assert_response :success
  end

  # GET /patients/:id
  test "should show patient" do
    get patient_path(@patient)
    assert_response :success
  end

  test "should show patient details" do
    get patient_path(@patient)
    assert_response :success
    assert_match @patient.name, response.body
  end

  # GET /patients/new
  test "should get new" do
    get new_patient_path
    assert_response :success
  end

  # POST /patients
  test "should create patient with valid data" do
    assert_difference("Patient.count", 1) do
      post patients_path, params: {
        patient: {
          name: "Novo Paciente Teste",
          cpf: "555.666.777-88",
          email: "novo.paciente@email.com",
          phone: "(11) 91234-5678",
          birth_date: "1990-05-15",
          address: "Rua Teste, 123"
        }
      }
    end
    assert_redirected_to patient_path(Patient.last)
    follow_redirect!
    assert_match "Paciente cadastrado com sucesso!", flash[:notice]
  end

  test "should not create patient with invalid data" do
    assert_no_difference("Patient.count") do
      post patients_path, params: {
        patient: {
          name: "",
          cpf: "invalid"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create patient with duplicate cpf" do
    assert_no_difference("Patient.count") do
      post patients_path, params: {
        patient: {
          name: "Duplicado",
          cpf: @patient.cpf
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # GET /patients/:id/edit
  test "should get edit" do
    get edit_patient_path(@patient)
    assert_response :success
  end

  # PATCH /patients/:id
  test "should update patient with valid data" do
    patch patient_path(@patient), params: {
      patient: {
        name: "Maria Silva Santos Atualizada",
        phone: "(11) 99999-0000"
      }
    }
    assert_redirected_to patient_path(@patient)
    follow_redirect!
    assert_match "Paciente atualizado com sucesso!", flash[:notice]
    @patient.reload
    assert_equal "Maria Silva Santos Atualizada", @patient.name
    assert_equal "(11) 99999-0000", @patient.phone
  end

  test "should not update patient with invalid data" do
    patch patient_path(@patient), params: {
      patient: {
        name: "",
        cpf: "invalid"
      }
    }
    assert_response :unprocessable_entity
  end

  # DELETE /patients/:id
  test "should destroy patient" do
    patient_to_delete = Patient.create!(
      name: "Paciente para Deletar",
      cpf: "999.888.777-66"
    )
    assert_difference("Patient.count", -1) do
      delete patient_path(patient_to_delete)
    end
    assert_redirected_to patients_path
    follow_redirect!
    assert_match "Paciente removido com sucesso!", flash[:notice]
  end
end
