require "test_helper"

class FamilyGroupMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get family_group_memberships_edit_url
    assert_response :success
  end

  test "should get update" do
    get family_group_memberships_update_url
    assert_response :success
  end
end
