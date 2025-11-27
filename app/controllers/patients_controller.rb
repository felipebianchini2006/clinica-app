class PatientsController < ApplicationController
  before_action :set_patient, only: [ :show, :edit, :update, :destroy ]

  def index
    @patients = Patient.search(params[:search]).order(:name).page(params[:page])
  end

  def show
    @appointments = @patient.appointments.includes(:practitioner).order(scheduled_at: :desc).limit(10)
    @medical_records = @patient.medical_records.includes(:practitioner).order(created_at: :desc).limit(5)
    @invoices = @patient.invoices.order(created_at: :desc).limit(5)
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)

    if @patient.save
      redirect_to @patient, notice: "Paciente cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @patient.update(patient_params)
      redirect_to @patient, notice: "Paciente atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_path, notice: "Paciente removido com sucesso!"
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(:name, :cpf, :birth_date, :phone, :email, :address, :notes)
  end
end
