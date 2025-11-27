class MedicalRecordsController < ApplicationController
  before_action :set_medical_record, only: [ :show, :edit, :update, :destroy ]

  def index
    @medical_records = MedicalRecord.includes(:patient, :practitioner)
                                    .for_patient(params[:patient_id])
                                    .search(params[:search])
                                    .order(created_at: :desc)
  end

  def show
  end

  def new
    @medical_record = MedicalRecord.new(
      patient_id: params[:patient_id],
      appointment_id: params[:appointment_id]
    )
    @patients = Patient.order(:name)
    @practitioners = Practitioner.order(:name)
  end

  def create
    @medical_record = MedicalRecord.new(medical_record_params)
    @medical_record.practitioner = current_user.practitioner if current_user.practitioner?

    if @medical_record.save
      redirect_to @medical_record, notice: "Prontuário criado com sucesso!"
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
    if @medical_record.update(medical_record_params)
      redirect_to @medical_record, notice: "Prontuário atualizado com sucesso!"
    else
      @patients = Patient.order(:name)
      @practitioners = Practitioner.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    patient = @medical_record.patient
    @medical_record.destroy
    redirect_to patient_path(patient), notice: "Prontuário removido com sucesso!"
  end

  private

  def set_medical_record
    @medical_record = MedicalRecord.find(params[:id])
  end

  def medical_record_params
    params.require(:medical_record).permit(:patient_id, :practitioner_id, :appointment_id, :diagnosis, :treatment, :notes, attachments: [])
  end
end
