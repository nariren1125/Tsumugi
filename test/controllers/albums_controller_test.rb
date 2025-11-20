require 'test_helper'

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: 'Test User', line_uid: 'test-uid')
  end

  test 'should get index' do
    log_in_as(@user)
    get albums_index_url
    assert_response :success
  end
end
