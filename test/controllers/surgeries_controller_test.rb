require "test_helper"

class SurgeriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get surgeries_index_url
    assert_response :success
  end

  test "should get show" do
    get surgeries_show_url
    assert_response :success
  end

  test "should get new" do
    get surgeries_new_url
    assert_response :success
  end

  test "should get create" do
    get surgeries_create_url
    assert_response :success
  end

  test "should get destroy" do
    get surgeries_destroy_url
    assert_response :success
  end
end
