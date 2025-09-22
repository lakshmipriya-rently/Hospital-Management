require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get home_index_url
    assert_response :success
  end

  test "should get redirect_by_role" do
    get home_redirect_by_role_url
    assert_response :success
  end
end
