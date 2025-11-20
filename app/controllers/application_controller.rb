class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def require_login
    redirect_to root_path, alert: t('flash.login.required') if current_user.blank?
  end

  allow_browser versions: :modern
end
