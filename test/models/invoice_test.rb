require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  def setup
    @fatura_paga = invoices(:maria_fatura_paga)
    @fatura_pendente = invoices(:joao_fatura_pendente)
    @fatura_atrasada = invoices(:ana_fatura_atrasada)
    @patient = patients(:maria)
  end

  # Validations
  test "should be valid with valid attributes" do
    invoice = Invoice.new(
      patient: @patient,
      amount: 150.00,
      due_date: 10.days.from_now,
      description: "Consulta de teste"
    )
    assert invoice.valid?
  end

  test "should require patient" do
    invoice = Invoice.new(
      amount: 150.00,
      due_date: 10.days.from_now
    )
    assert_not invoice.valid?
    assert_includes invoice.errors[:patient], "must exist"
  end

  test "should require amount" do
    invoice = Invoice.new(
      patient: @patient,
      due_date: 10.days.from_now
    )
    assert_not invoice.valid?
    assert_includes invoice.errors[:amount], "can't be blank"
  end

  test "should require positive amount" do
    invoice = Invoice.new(
      patient: @patient,
      amount: 0,
      due_date: 10.days.from_now
    )
    assert_not invoice.valid?
    assert_includes invoice.errors[:amount], "must be greater than 0"
  end

  test "should require due_date" do
    invoice = Invoice.new(
      patient: @patient,
      amount: 150.00
    )
    assert_not invoice.valid?
    assert_includes invoice.errors[:due_date], "can't be blank"
  end

  test "should allow appointment to be optional" do
    invoice = Invoice.new(
      patient: @patient,
      amount: 150.00,
      due_date: 10.days.from_now
    )
    assert invoice.valid?
  end

  # Enums
  test "should have correct status enum values" do
    assert_equal 0, Invoice.statuses[:pending]
    assert_equal 1, Invoice.statuses[:paid]
    assert_equal 2, Invoice.statuses[:overdue]
    assert_equal 3, Invoice.statuses[:cancelled]
  end

  test "paid invoice should have paid status" do
    assert @fatura_paga.paid?
  end

  test "pending invoice should have pending status" do
    assert @fatura_pendente.pending?
  end

  # Scopes
  test "pending scope returns pending invoices" do
    pending_invoices = Invoice.pending
    assert_includes pending_invoices, @fatura_pendente
    assert_includes pending_invoices, @fatura_atrasada
    assert_not_includes pending_invoices, @fatura_paga
  end

  test "paid scope returns paid invoices" do
    paid_invoices = Invoice.paid
    assert_includes paid_invoices, @fatura_paga
    assert_not_includes paid_invoices, @fatura_pendente
  end

  test "overdue scope returns pending invoices past due date" do
    overdue_invoices = Invoice.overdue
    assert_includes overdue_invoices, @fatura_atrasada
    assert_not_includes overdue_invoices, @fatura_pendente
    assert_not_includes overdue_invoices, @fatura_paga
  end

  test "for_period scope filters by date range" do
    start_date = 10.days.ago.to_date
    end_date = Date.current
    invoices = Invoice.for_period(start_date, end_date)
    assert invoices.all? { |i| i.due_date >= start_date && i.due_date <= end_date }
  end

  test "for_patient scope filters by patient" do
    maria_invoices = Invoice.for_patient(@patient.id)
    assert maria_invoices.all? { |i| i.patient_id == @patient.id }
    assert_includes maria_invoices, @fatura_paga
  end

  # Methods
  test "mark_as_paid should update status and set paid_at" do
    invoice = Invoice.create!(
      patient: @patient,
      amount: 200.00,
      due_date: 5.days.from_now,
      status: :pending
    )
    assert invoice.pending?
    assert_nil invoice.paid_at

    invoice.mark_as_paid!
    invoice.reload

    assert invoice.paid?
    assert_not_nil invoice.paid_at
  end

  test "overdue? returns true for pending invoice past due date" do
    assert @fatura_atrasada.overdue?
  end

  test "overdue? returns false for pending invoice not past due date" do
    assert_not @fatura_pendente.overdue?
  end

  test "overdue? returns false for paid invoice" do
    assert_not @fatura_paga.overdue?
  end

  # Associations
  test "should belong to patient" do
    assert_equal @patient, @fatura_paga.patient
  end

  test "should belong to appointment optionally" do
    assert_respond_to @fatura_paga, :appointment
    assert_equal appointments(:maria_consulta_passada), @fatura_paga.appointment
  end
end
