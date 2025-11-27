require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    @doctor = users(:doctor_carlos)
    @appointment = appointments(:maria_consulta)
    @patient = patients(:maria)
    @practitioner = practitioners(:dr_carlos)
    # Login as admin for all tests
    post session_path, params: { email: @admin.email, password: "password123" }
  end

  # Authentication
  test "should redirect to login when not authenticated" do
    delete session_path
    get appointments_path
    assert_redirected_to new_session_path
  end

  # GET /appointments
  test "should get index" do
    get appointments_path
    assert_response :success
  end

  test "should filter appointments by practitioner" do
    get appointments_path, params: { practitioner_id: @practitioner.id }
    assert_response :success
  end

  test "should filter today appointments" do
    get appointments_path, params: { today: true }
    assert_response :success
  end

  test "should filter upcoming appointments" do
    get appointments_path, params: { upcoming: true }
    assert_response :success
  end

  # GET /appointments/calendar
  test "should get calendar" do
    get calendar_appointments_path
    assert_response :success
  end

  test "should get calendar as json" do
    get calendar_appointments_path, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  # GET /appointments/:id
  test "should show appointment" do
    get appointment_path(@appointment)
    assert_response :success
  end

  # GET /appointments/new
  test "should get new" do
    get new_appointment_path
    assert_response :success
  end

  test "should get new with patient prefilled" do
    get new_appointment_path, params: { patient_id: @patient.id }
    assert_response :success
  end

  # POST /appointments
  test "should create appointment with valid data" do
    assert_difference("Appointment.count", 1) do
      post appointments_path, params: {
        appointment: {
          patient_id: @patient.id,
          practitioner_id: practitioners(:dra_patricia).id,
          scheduled_at: 7.days.from_now.change(hour: 11, min: 0),
          duration_minutes: 30,
          status: :scheduled,
          notes: "Nova consulta de teste"
        }
      }
    end
    assert_redirected_to appointment_path(Appointment.last)
    follow_redirect!
    assert_match "Consulta agendada com sucesso!", flash[:notice]
  end

  test "should not create appointment without patient" do
    assert_no_difference("Appointment.count") do
      post appointments_path, params: {
        appointment: {
          practitioner_id: @practitioner.id,
          scheduled_at: 7.days.from_now,
          duration_minutes: 30
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create appointment in the past" do
    assert_no_difference("Appointment.count") do
      post appointments_path, params: {
        appointment: {
          patient_id: @patient.id,
          practitioner_id: @practitioner.id,
          scheduled_at: 1.day.ago,
          duration_minutes: 30
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # GET /appointments/:id/edit
  test "should get edit" do
    get edit_appointment_path(@appointment)
    assert_response :success
  end

  # PATCH /appointments/:id
  test "should update appointment" do
    patch appointment_path(@appointment), params: {
      appointment: {
        notes: "Notas atualizadas para teste",
        duration_minutes: 45
      }
    }
    assert_redirected_to appointment_path(@appointment)
    follow_redirect!
    assert_match "Consulta atualizada com sucesso!", flash[:notice]
    @appointment.reload
    assert_equal "Notas atualizadas para teste", @appointment.notes
    assert_equal 45, @appointment.duration_minutes
  end

  # DELETE /appointments/:id
  test "should destroy appointment" do
    appointment_to_delete = Appointment.create!(
      patient: @patient,
      practitioner: practitioners(:dra_patricia),
      scheduled_at: 20.days.from_now,
      duration_minutes: 30
    )
    assert_difference("Appointment.count", -1) do
      delete appointment_path(appointment_to_delete)
    end
    assert_redirected_to appointments_path
    follow_redirect!
    assert_match "Consulta cancelada com sucesso!", flash[:notice]
  end
end
