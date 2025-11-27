class ReportsController < ApplicationController
  def index
    @start_date = params[:start_date]&.to_date || Date.current.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.current.end_of_month
  end

  def financial
    @start_date = params[:start_date]&.to_date || Date.current.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.current.end_of_month

    @invoices = Invoice.for_period(@start_date, @end_date)
    @total_revenue = @invoices.paid.sum(:amount)
    @total_pending = @invoices.pending.sum(:amount)
    @total_overdue = @invoices.overdue.sum(:amount)

    @revenue_by_practitioner = Appointment.joins(:invoice, :practitioner)
                                          .where(invoices: { status: :paid, paid_at: @start_date..@end_date })
                                          .group("practitioners.name")
                                          .sum("invoices.amount")

    @appointments_count = Appointment.for_date_range(@start_date, @end_date).count
    @completed_appointments = Appointment.for_date_range(@start_date, @end_date).completed.count
    @cancelled_appointments = Appointment.for_date_range(@start_date, @end_date).cancelled.count
  end

  def export
    @start_date = params[:start_date]&.to_date || Date.current.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.current.end_of_month

    @invoices = Invoice.includes(:patient, :appointment)
                       .for_period(@start_date, @end_date)
                       .order(:due_date)

    respond_to do |format|
      format.csv do
        headers["Content-Disposition"] = "attachment; filename=relatorio_financeiro_#{@start_date}_#{@end_date}.csv"
        headers["Content-Type"] = "text/csv; charset=utf-8"
      end
    end
  end
end
