require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def create
    user = User.find(params[:id])
    session[:user_id] = user.id
    head :ok
  end

  test 'should get callback' do
    get sessions_callback_url
    assert_response :success
  end

  test 'should get destroy' do
    get sessions_destroy_url
    assert_redirected_to root_url
  end
end
