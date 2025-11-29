require 'test_helper'

class ChildrenControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @family_group = family_groups(:one)

    log_in_as(@user)
  end

  test 'should get new' do
    get new_child_url
    assert_response :success
  end

  test 'should create child' do
    assert_difference('Child.count', 1) do
      post children_url, params: {
        child: {
          name: 'テスト太郎',
          birth_date: '2020-01-01'
        }
      }
    end

    assert_redirected_to family_settings_url
  end
end
