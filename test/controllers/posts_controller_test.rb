require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as(@user)
  end

  test 'should redirect new when no pending photos' do
    get new_post_url
    assert_redirected_to select_photos_posts_url
  end
end
