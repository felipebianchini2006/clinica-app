class InvoicesController < ApplicationController
  before_action :set_invoice, only: [ :show, :edit, :update, :destroy, :mark_paid ]

  def index
    @invoices = Invoice.includes(:patient, :appointment)
                       .for_patient(params[:patient_id])
                       .for_period(params[:start_date]&.to_date, params[:end_date]&.to_date)
                       .order(created_at: :desc)

    @invoices = @invoices.pending if params[:status] == "pending"
    @invoices = @invoices.paid if params[:status] == "paid"
    @invoices = @invoices.overdue if params[:status] == "overdue"

    @total_pending = Invoice.pending.sum(:amount)
    @total_paid_month = Invoice.paid.where(paid_at: Date.current.all_month).sum(:amount)
  end

  def show
  end

  def new
    @invoice = Invoice.new(
      patient_id: params[:patient_id],
      appointment_id: params[:appointment_id],
      due_date: Date.current + 7.days
    )
    @patients = Patient.order(:name)
    @appointments = Appointment.includes(:patient).completed.order(scheduled_at: :desc).limit(50)
  end

  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      redirect_to @invoice, notice: "Fatura criada com sucesso!"
    else
      @patients = Patient.order(:name)
      @appointments = Appointment.includes(:patient).completed.order(scheduled_at: :desc).limit(50)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @patients = Patient.order(:name)
    @appointments = Appointment.includes(:patient).order(scheduled_at: :desc).limit(50)
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Fatura atualizada com sucesso!"
    else
      @patients = Patient.order(:name)
      @appointments = Appointment.includes(:patient).order(scheduled_at: :desc).limit(50)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Fatura removida com sucesso!"
  end

  def mark_paid
    @invoice.mark_as_paid!
    redirect_to @invoice, notice: "Fatura marcada como paga!"
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:patient_id, :appointment_id, :amount, :status, :due_date, :description)
  end
end
