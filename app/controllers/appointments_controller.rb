class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]

  def index
    @appointments = Appointment.includes(:patient, :practitioner)
                               .for_practitioner(params[:practitioner_id])
                               .for_date_range(params[:start_date]&.to_date, params[:end_date]&.to_date)
                               .order(:scheduled_at)

    @appointments = @appointments.today if params[:today].present?
    @appointments = @appointments.upcoming if params[:upcoming].present?
  end

  def calendar
    @practitioners = Practitioner.order(:name)
    @selected_practitioner = params[:practitioner_id]

    start_date = params[:start]&.to_date || Date.current.beginning_of_month
    end_date = params[:end]&.to_date || Date.current.end_of_month

    @appointments = Appointment.includes(:patient, :practitioner)
                               .for_practitioner(@selected_practitioner)
                               .for_date_range(start_date, end_date)

    respond_to do |format|
      format.html
      format.json do
        render json: @appointments.map { |apt|
          {
            id: apt.id,
            title: "#{apt.patient.name} - #{apt.practitioner.name}",
            start: apt.scheduled_at.iso8601,
            end: apt.end_time.iso8601,
            url: appointment_path(apt),
            backgroundColor: status_color(apt.status),
            extendedProps: {
              status: apt.status,
              patient: apt.patient.name,
              practitioner: apt.practitioner.name
            }
          }
        }
      end
    end
  end

  def show
  end

  def new
    @appointment = Appointment.new(
      patient_id: params[:patient_id],
      practitioner_id: params[:practitioner_id],
      scheduled_at: params[:scheduled_at] || Time.current.beginning_of_hour + 1.hour
    )
    @patients = Patient.order(:name)
    @practitioners = Practitioner.order(:name)
  end

  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
      respond_to do |format|
        format.html { redirect_to @appointment, notice: "Consulta agendada com sucesso!" }
        format.turbo_stream { redirect_to calendar_appointments_path, notice: "Consulta agendada com sucesso!" }
      end
    else
      @patients = Patient.order(:name)
      @practitioners = Practitioner.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @patients = Patient.order(:name)
    @practitioners = Practitioner.order(:name)
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to @appointment, notice: "Consulta atualizada com sucesso!"
    else
      @patients = Patient.order(:name)
      @practitioners = Practitioner.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.destroy
    redirect_to appointments_path, notice: "Consulta cancelada com sucesso!"
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:patient_id, :practitioner_id, :scheduled_at, :duration_minutes, :status, :notes)
  end

  def status_color(status)
    case status
    when "scheduled" then "#3B82F6"   # blue
    when "confirmed" then "#10B981"   # green
    when "in_progress" then "#F59E0B" # yellow
    when "completed" then "#6B7280"   # gray
    when "cancelled" then "#EF4444"   # red
    when "no_show" then "#8B5CF6"     # purple
    else "#3B82F6"
    end
  end
end
