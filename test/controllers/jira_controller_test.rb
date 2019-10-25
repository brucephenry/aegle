require 'test_helper'

class JiraControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jira_index_url
    assert_response :success
  end

end
