require "test_helper"

class FamilyGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # fixture がある場合
    @family_group = family_groups(:one)

    log_in_as(@user)  # ← すでに test_helper に定義済みの想定
  end

  test "should get edit" do
    get edit_family_group_url(@family_group)
    assert_response :success
  end

  test "should update family_group" do
    patch family_group_path(@family_group), params: {
      family_group: { name: "New Name" }
    }

    assert_redirected_to edit_family_group_url(@family_group)
    @family_group.reload
    assert_equal "New Name", @family_group.name
  end

  test "should get settings" do
    get family_settings_url
    assert_response :success
  end
end
