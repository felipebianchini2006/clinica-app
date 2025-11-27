require "test_helper"

class PractitionersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    @receptionist = users(:receptionist)
    @practitioner = practitioners(:dr_carlos)
    # Login as admin for all tests by default
    post session_path, params: { email: @admin.email, password: "password123" }
  end

  # Authentication
  test "should redirect to login when not authenticated" do
    delete session_path
    get practitioners_path
    assert_redirected_to new_session_path
  end

  # GET /practitioners
  test "should get index" do
    get practitioners_path
    assert_response :success
  end

  test "should search practitioners by name" do
    get practitioners_path, params: { search: "Carlos" }
    assert_response :success
  end

  test "should search practitioners by specialty" do
    get practitioners_path, params: { search: "Pediatria" }
    assert_response :success
  end

  # GET /practitioners/:id
  test "should show practitioner" do
    get practitioner_path(@practitioner)
    assert_response :success
  end

  # GET /practitioners/new
  test "should get new for admin" do
    get new_practitioner_path
    assert_response :success
  end

  test "should redirect new for non-admin" do
    delete session_path
    post session_path, params: { email: @receptionist.email, password: "password123" }
    get new_practitioner_path
    assert_redirected_to practitioners_path
    follow_redirect!
    assert_match "Você não tem permissão", flash[:alert]
  end

  # POST /practitioners
  test "should create practitioner for admin" do
    # Criar um user primeiro para associar ao practitioner
    new_user = User.create!(
      name: "Dr. Novo Usuário",
      email: "novo.medico@clinica.com",
      password: "password123",
      role: :practitioner
    )
    assert_difference("Practitioner.count", 1) do
      post practitioners_path, params: {
        practitioner: {
          name: "Dr. Novo Teste",
          specialty: "Dermatologia",
          crm: "CRM-SP 888888",
          phone: "(11) 5555-5555",
          user_id: new_user.id
        }
      }
    end
    assert_redirected_to practitioner_path(Practitioner.last)
    follow_redirect!
    assert_match "Profissional cadastrado com sucesso!", flash[:notice]
  end

  test "should redirect create for non-admin" do
    delete session_path
    post session_path, params: { email: @receptionist.email, password: "password123" }
    assert_no_difference("Practitioner.count") do
      post practitioners_path, params: {
        practitioner: {
          name: "Dr. Teste",
          specialty: "Test",
          crm: "CRM-SP 999999"
        }
      }
    end
    assert_redirected_to practitioners_path
  end

  test "should not create practitioner with invalid data" do
    assert_no_difference("Practitioner.count") do
      post practitioners_path, params: {
        practitioner: {
          name: "",
          specialty: "",
          crm: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create practitioner with duplicate crm" do
    assert_no_difference("Practitioner.count") do
      post practitioners_path, params: {
        practitioner: {
          name: "Duplicado",
          specialty: "Test",
          crm: @practitioner.crm
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # GET /practitioners/:id/edit
  test "should get edit for admin" do
    get edit_practitioner_path(@practitioner)
    assert_response :success
  end

  test "should redirect edit for non-admin" do
    delete session_path
    post session_path, params: { email: @receptionist.email, password: "password123" }
    get edit_practitioner_path(@practitioner)
    assert_redirected_to practitioners_path
  end

  # PATCH /practitioners/:id
  test "should update practitioner for admin" do
    patch practitioner_path(@practitioner), params: {
      practitioner: {
        specialty: "Cardiologia",
        phone: "(11) 1111-1111"
      }
    }
    assert_redirected_to practitioner_path(@practitioner)
    follow_redirect!
    assert_match "Profissional atualizado com sucesso!", flash[:notice]
    @practitioner.reload
    assert_equal "Cardiologia", @practitioner.specialty
  end

  # DELETE /practitioners/:id
  test "should destroy practitioner for admin" do
    # Criar user e practitioner para deletar
    user_to_delete = User.create!(
      name: "Dr. Para Deletar",
      email: "deletar@clinica.com",
      password: "password123",
      role: :practitioner
    )
    practitioner_to_delete = Practitioner.create!(
      name: "Dr. Para Deletar",
      specialty: "Test",
      crm: "CRM-SP 111222",
      user: user_to_delete
    )
    assert_difference("Practitioner.count", -1) do
      delete practitioner_path(practitioner_to_delete)
    end
    assert_redirected_to practitioners_path
    follow_redirect!
    assert_match "Profissional removido com sucesso!", flash[:notice]
  end

  test "should redirect destroy for non-admin" do
    delete session_path
    post session_path, params: { email: @receptionist.email, password: "password123" }
    assert_no_difference("Practitioner.count") do
      delete practitioner_path(@practitioner)
    end
    assert_redirected_to practitioners_path
  end
end
