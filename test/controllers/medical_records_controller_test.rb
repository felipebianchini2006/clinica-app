require "test_helper"

class MedicalRecordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    @doctor = users(:doctor_carlos)
    @medical_record = medical_records(:maria_prontuario)
    @patient = patients(:maria)
    @practitioner = practitioners(:dr_carlos)
    @appointment = appointments(:maria_consulta_passada)
    # Login as admin for all tests
    post session_path, params: { email: @admin.email, password: "password123" }
  end

  # Authentication
  test "should redirect to login when not authenticated" do
    delete session_path
    get medical_records_path
    assert_redirected_to new_session_path
  end

  # GET /medical_records
  test "should get index" do
    get medical_records_path
    assert_response :success
  end

  test "should filter by patient" do
    get medical_records_path, params: { patient_id: @patient.id }
    assert_response :success
  end

  test "should search by diagnosis" do
    get medical_records_path, params: { search: "Hipertensão" }
    assert_response :success
  end

  # GET /medical_records/:id
  test "should show medical record" do
    get medical_record_path(@medical_record)
    assert_response :success
  end

  # GET /medical_records/new
  test "should get new" do
    get new_medical_record_path
    assert_response :success
  end

  test "should get new with patient prefilled" do
    get new_medical_record_path, params: { patient_id: @patient.id }
    assert_response :success
  end

  # POST /medical_records
  test "should create medical record" do
    # Criar um novo appointment para associar (data futura, depois ajustamos para completed)
    new_appointment = Appointment.create!(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 1.day.from_now,
      duration_minutes: 30,
      status: :scheduled
    )
    # Atualizar para status completed (simula consulta realizada)
    new_appointment.update_columns(scheduled_at: 1.day.ago, status: :completed)
    
    assert_difference("MedicalRecord.count", 1) do
      post medical_records_path, params: {
        medical_record: {
          patient_id: @patient.id,
          practitioner_id: @practitioner.id,
          appointment_id: new_appointment.id,
          diagnosis: "Diagnóstico de teste",
          treatment: "Tratamento de teste",
          notes: "Observações de teste"
        }
      }
    end
    assert_redirected_to medical_record_path(MedicalRecord.last)
    follow_redirect!
    assert_match "Prontuário criado com sucesso!", flash[:notice]
  end

  test "should not create medical record without patient" do
    assert_no_difference("MedicalRecord.count") do
      post medical_records_path, params: {
        medical_record: {
          practitioner_id: @practitioner.id,
          diagnosis: "Teste"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create medical record without diagnosis" do
    assert_no_difference("MedicalRecord.count") do
      post medical_records_path, params: {
        medical_record: {
          patient_id: @patient.id,
          practitioner_id: @practitioner.id,
          diagnosis: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # GET /medical_records/:id/edit
  test "should get edit" do
    get edit_medical_record_path(@medical_record)
    assert_response :success
  end

  # PATCH /medical_records/:id
  test "should update medical record" do
    patch medical_record_path(@medical_record), params: {
      medical_record: {
        diagnosis: "Diagnóstico atualizado",
        treatment: "Tratamento atualizado"
      }
    }
    assert_redirected_to medical_record_path(@medical_record)
    follow_redirect!
    assert_match "Prontuário atualizado com sucesso!", flash[:notice]
    @medical_record.reload
    assert_equal "Diagnóstico atualizado", @medical_record.diagnosis
  end

  # DELETE /medical_records/:id
  test "should destroy medical record" do
    # Criar appointment para o medical record (primeiro com data futura para passar validação)
    appointment_for_delete = Appointment.create!(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 2.days.from_now,
      duration_minutes: 30,
      status: :scheduled
    )
    # Atualizar para simular consulta realizada no passado
    appointment_for_delete.update_columns(scheduled_at: 2.days.ago, status: :completed)
    
    medical_record_to_delete = MedicalRecord.create!(
      patient: @patient,
      practitioner: @practitioner,
      appointment: appointment_for_delete,
      diagnosis: "Para deletar"
    )
    patient_id = medical_record_to_delete.patient_id
    assert_difference("MedicalRecord.count", -1) do
      delete medical_record_path(medical_record_to_delete)
    end
    assert_redirected_to patient_path(patient_id)
    follow_redirect!
    assert_match "Prontuário removido com sucesso!", flash[:notice]
  end
end
