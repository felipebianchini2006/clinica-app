require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    @fatura_paga = invoices(:maria_fatura_paga)
    @fatura_pendente = invoices(:joao_fatura_pendente)
    @patient = patients(:maria)
    # Login as admin for all tests
    post session_path, params: { email: @admin.email, password: "password123" }
  end

  # Authentication
  test "should redirect to login when not authenticated" do
    delete session_path
    get invoices_path
    assert_redirected_to new_session_path
  end

  # GET /invoices
  test "should get index" do
    get invoices_path
    assert_response :success
  end

  test "should filter pending invoices" do
    get invoices_path, params: { status: "pending" }
    assert_response :success
  end

  test "should filter paid invoices" do
    get invoices_path, params: { status: "paid" }
    assert_response :success
  end

  test "should filter overdue invoices" do
    get invoices_path, params: { status: "overdue" }
    assert_response :success
  end

  test "should filter by patient" do
    get invoices_path, params: { patient_id: @patient.id }
    assert_response :success
  end

  # GET /invoices/:id
  test "should show invoice" do
    get invoice_path(@fatura_paga)
    assert_response :success
  end

  # GET /invoices/new
  test "should get new" do
    get new_invoice_path
    assert_response :success
  end

  test "should get new with patient prefilled" do
    get new_invoice_path, params: { patient_id: @patient.id }
    assert_response :success
  end

  # POST /invoices
  test "should create invoice with valid data" do
    assert_difference("Invoice.count", 1) do
      post invoices_path, params: {
        invoice: {
          patient_id: @patient.id,
          amount: 350.00,
          due_date: 15.days.from_now.to_date,
          description: "Nova fatura de teste",
          status: :pending
        }
      }
    end
    assert_redirected_to invoice_path(Invoice.last)
    follow_redirect!
    assert_match "Fatura criada com sucesso!", flash[:notice]
  end

  test "should not create invoice without patient" do
    assert_no_difference("Invoice.count") do
      post invoices_path, params: {
        invoice: {
          amount: 350.00,
          due_date: 15.days.from_now.to_date
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create invoice without amount" do
    assert_no_difference("Invoice.count") do
      post invoices_path, params: {
        invoice: {
          patient_id: @patient.id,
          due_date: 15.days.from_now.to_date
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create invoice with zero amount" do
    assert_no_difference("Invoice.count") do
      post invoices_path, params: {
        invoice: {
          patient_id: @patient.id,
          amount: 0,
          due_date: 15.days.from_now.to_date
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # GET /invoices/:id/edit
  test "should get edit" do
    get edit_invoice_path(@fatura_pendente)
    assert_response :success
  end

  # PATCH /invoices/:id
  test "should update invoice" do
    patch invoice_path(@fatura_pendente), params: {
      invoice: {
        amount: 450.00,
        description: "Descrição atualizada"
      }
    }
    assert_redirected_to invoice_path(@fatura_pendente)
    follow_redirect!
    assert_match "Fatura atualizada com sucesso!", flash[:notice]
    @fatura_pendente.reload
    assert_equal 450.00, @fatura_pendente.amount
    assert_equal "Descrição atualizada", @fatura_pendente.description
  end

  # DELETE /invoices/:id
  test "should destroy invoice" do
    invoice_to_delete = Invoice.create!(
      patient: @patient,
      amount: 100.00,
      due_date: 30.days.from_now.to_date,
      description: "Fatura para deletar"
    )
    assert_difference("Invoice.count", -1) do
      delete invoice_path(invoice_to_delete)
    end
    assert_redirected_to invoices_path
    follow_redirect!
    assert_match "Fatura removida com sucesso!", flash[:notice]
  end

  # PATCH /invoices/:id/mark_paid
  test "should mark invoice as paid" do
    patch mark_paid_invoice_path(@fatura_pendente)
    assert_redirected_to invoice_path(@fatura_pendente)
    follow_redirect!
    assert_match "Fatura marcada como paga!", flash[:notice]
    @fatura_pendente.reload
    assert @fatura_pendente.paid?
    assert_not_nil @fatura_pendente.paid_at
  end
end
