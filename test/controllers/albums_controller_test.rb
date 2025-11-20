require 'test_helper'

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: 'Test User', line_uid: 'test-uid')
    @album = albums(:one)
  end

  test 'should get index' do
    # ログイン状態を作る
    begin
      post login_path, params: { line_uid: @user.line_uid }
    rescue StandardError
      nil
    end
    # もしくは session を強制的に書き換える
    @controller.session[:user_id] = @user.id

    get albums_index_url
    assert_response :success
  end
end
