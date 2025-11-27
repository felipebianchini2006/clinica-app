require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    post session_path, params: { email: @admin.email, password: "password123" }
  end

  test "should redirect to login when not authenticated" do
    delete session_path
    get root_path
    assert_redirected_to new_session_path
  end

  test "should get index when authenticated" do
    get root_path
    assert_response :success
  end
end
