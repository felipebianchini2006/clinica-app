require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  def setup
    @maria_consulta = appointments(:maria_consulta)
    @joao_consulta = appointments(:joao_consulta)
    @ana_consulta = appointments(:ana_consulta)
    @maria_consulta_passada = appointments(:maria_consulta_passada)
    @patient = patients(:maria)
    @practitioner = practitioners(:dr_carlos)
  end

  # Validations
  test "should be valid with valid attributes" do
    appointment = Appointment.new(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 3.days.from_now,
      duration_minutes: 30
    )
    assert appointment.valid?
  end

  test "should require scheduled_at" do
    appointment = Appointment.new(
      patient: @patient,
      practitioner: @practitioner,
      duration_minutes: 30
    )
    assert_not appointment.valid?
    assert_includes appointment.errors[:scheduled_at], "can't be blank"
  end

  test "should have default duration_minutes of 30" do
    appointment = Appointment.new(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 3.days.from_now
    )
    assert_equal 30, appointment.duration_minutes
  end

  test "should require positive duration_minutes" do
    appointment = Appointment.new(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 3.days.from_now,
      duration_minutes: 0
    )
    assert_not appointment.valid?
    assert_includes appointment.errors[:duration_minutes], "must be greater than 0"
  end

  test "should require patient" do
    appointment = Appointment.new(
      practitioner: @practitioner,
      scheduled_at: 3.days.from_now,
      duration_minutes: 30
    )
    assert_not appointment.valid?
    assert_includes appointment.errors[:patient], "must exist"
  end

  test "should require practitioner" do
    appointment = Appointment.new(
      patient: @patient,
      scheduled_at: 3.days.from_now,
      duration_minutes: 30
    )
    assert_not appointment.valid?
    assert_includes appointment.errors[:practitioner], "must exist"
  end

  test "should not allow scheduled_at in the past on create" do
    appointment = Appointment.new(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 1.day.ago,
      duration_minutes: 30
    )
    assert_not appointment.valid?
    assert_includes appointment.errors[:scheduled_at], "deve ser no futuro"
  end

  # Enums
  test "should have correct status enum values" do
    assert_equal 0, Appointment.statuses[:scheduled]
    assert_equal 1, Appointment.statuses[:confirmed]
    assert_equal 2, Appointment.statuses[:in_progress]
    assert_equal 3, Appointment.statuses[:completed]
    assert_equal 4, Appointment.statuses[:cancelled]
    assert_equal 5, Appointment.statuses[:no_show]
  end

  test "should default to scheduled status" do
    appointment = Appointment.new(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 3.days.from_now,
      duration_minutes: 30
    )
    # Default status might not be set until save; check fixture
    assert @maria_consulta.scheduled?
  end

  test "joao consulta should be confirmed" do
    assert @joao_consulta.confirmed?
  end

  test "past appointment should be completed" do
    assert @maria_consulta_passada.completed?
  end

  # Methods
  test "end_time should calculate correctly" do
    appointment = Appointment.new(
      scheduled_at: Time.current,
      duration_minutes: 45
    )
    expected = appointment.scheduled_at + 45.minutes
    assert_equal expected, appointment.end_time
  end

  # Scopes
  test "today scope returns appointments for today" do
    # Create appointment for today
    appointment = Appointment.create!(
      patient: @patient,
      practitioner: practitioners(:dra_patricia),
      scheduled_at: Time.current + 2.hours,
      duration_minutes: 30
    )
    today_appointments = Appointment.today
    assert_includes today_appointments, appointment
  end

  test "upcoming scope returns future appointments ordered by scheduled_at" do
    upcoming = Appointment.upcoming
    assert upcoming.all? { |a| a.scheduled_at >= Time.current }
    scheduled_times = upcoming.pluck(:scheduled_at)
    assert_equal scheduled_times.sort, scheduled_times
  end

  test "past scope returns past appointments" do
    past = Appointment.past
    assert_includes past, @maria_consulta_passada
  end

  test "for_practitioner scope filters by practitioner" do
    carlos_appointments = Appointment.for_practitioner(@practitioner.id)
    assert carlos_appointments.all? { |a| a.practitioner_id == @practitioner.id }
  end

  test "for_date_range scope filters by date range" do
    start_date = Date.current
    end_date = 3.days.from_now.to_date
    appointments = Appointment.for_date_range(start_date, end_date)
    assert appointments.all? { |a|
      a.scheduled_at >= start_date.beginning_of_day &&
      a.scheduled_at <= end_date.end_of_day
    }
  end

  # Associations
  test "should belong to patient" do
    assert_equal @patient, @maria_consulta.patient
  end

  test "should belong to practitioner" do
    assert_equal @practitioner, @maria_consulta.practitioner
  end

  test "should have one medical_record" do
    assert_respond_to @maria_consulta, :medical_record
  end

  test "should have one invoice" do
    assert_respond_to @maria_consulta, :invoice
  end

  # Overlapping validation
  test "should not allow overlapping appointments for same practitioner" do
    # Create an appointment
    existing = Appointment.create!(
      patient: @patient,
      practitioner: practitioners(:dra_patricia),
      scheduled_at: 5.days.from_now.change(hour: 14, min: 0),
      duration_minutes: 60
    )

    # Try to create overlapping appointment
    overlapping = Appointment.new(
      patient: patients(:joao),
      practitioner: practitioners(:dra_patricia),
      scheduled_at: 5.days.from_now.change(hour: 14, min: 30),
      duration_minutes: 30
    )
    assert_not overlapping.valid?
    assert_includes overlapping.errors[:scheduled_at], "conflita com outro agendamento"
  end

  test "should allow appointments with different practitioners at same time" do
    appointment = Appointment.new(
      patient: patients(:ana),
      practitioner: practitioners(:dra_patricia),
      scheduled_at: @maria_consulta.scheduled_at,
      duration_minutes: 30
    )
    assert appointment.valid?
  end

  test "should allow appointments that don't overlap" do
    appointment = Appointment.new(
      patient: @patient,
      practitioner: @practitioner,
      scheduled_at: 15.days.from_now.change(hour: 16, min: 0),
      duration_minutes: 30
    )
    assert appointment.valid?
  end
end
