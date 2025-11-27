require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @admin = users(:admin)
    @doctor = users(:doctor_carlos)
    @receptionist = users(:receptionist)
  end

  # Validations
  test "should be valid with valid attributes" do
    user = User.new(
      name: "Novo Usuário",
      email: "novo@clinica.com",
      password: "senha123",
      role: :receptionist
    )
    assert user.valid?
  end

  test "should require name" do
    user = User.new(email: "test@test.com", password: "password", role: :admin)
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email" do
    user = User.new(name: "Test", password: "password", role: :admin)
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    user = User.new(name: "Test", email: "invalid-email", password: "password", role: :admin)
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "should require unique email" do
    user = User.new(name: "Test", email: @admin.email, password: "password", role: :admin)
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "should default to receptionist role" do
    user = User.new(name: "Test", email: "test@test.com", password: "password")
    assert user.valid?
    assert_equal "receptionist", user.role
  end

  # Email normalization
  test "should normalize email to lowercase" do
    user = User.new(
      name: "Test",
      email: "  TEST@EMAIL.COM  ",
      password: "password",
      role: :admin
    )
    assert_equal "test@email.com", user.email
  end

  # Roles
  test "should have correct role enum values" do
    assert_equal 0, User.roles[:receptionist]
    assert_equal 1, User.roles[:practitioner]
    assert_equal 2, User.roles[:admin]
  end

  test "admin should be admin" do
    assert @admin.admin?
    assert_not @admin.receptionist?
    assert_not @admin.practitioner?
  end

  test "doctor should be practitioner" do
    assert @doctor.practitioner?
    assert_not @doctor.admin?
    assert_not @doctor.receptionist?
  end

  test "receptionist should be receptionist" do
    assert @receptionist.receptionist?
    assert_not @receptionist.admin?
    assert_not @receptionist.practitioner?
  end

  # Associations
  test "should have one practitioner" do
    assert_respond_to @doctor, :practitioner
  end

  # Authentication
  test "should authenticate with correct password" do
    user = User.new(
      name: "Test",
      email: "auth@test.com",
      password: "senha123",
      role: :admin
    )
    user.save!
    assert user.authenticate("senha123")
    assert_not user.authenticate("wrong_password")
  end
end
