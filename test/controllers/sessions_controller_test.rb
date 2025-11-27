require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    @doctor = users(:doctor_carlos)
  end

  # GET /login
  test "should get new (login page)" do
    get new_session_path
    assert_response :success
  end

  # POST /session
  test "should create session with valid credentials" do
    post session_path, params: { email: @admin.email, password: "password123" }
    assert_redirected_to root_path
    assert_equal @admin.id, session[:user_id]
    follow_redirect!
    assert_match "Login realizado com sucesso!", flash[:notice]
  end

  test "should not create session with invalid email" do
    post session_path, params: { email: "wrong@email.com", password: "password123" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_match "Email ou senha inválidos", flash[:alert]
  end

  test "should not create session with invalid password" do
    post session_path, params: { email: @admin.email, password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_match "Email ou senha inválidos", flash[:alert]
  end

  # DELETE /session
  test "should destroy session (logout)" do
    # First login
    post session_path, params: { email: @admin.email, password: "password123" }
    assert_equal @admin.id, session[:user_id]

    # Then logout
    delete session_path
    assert_nil session[:user_id]
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "Logout realizado com sucesso!", flash[:notice]
  end
end
