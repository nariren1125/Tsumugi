class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    process_line_login
  end

  def destroy
    reset_session
    redirect_to root_path, notice: t('flash.logout.success')
  end

  private

  def process_line_login
    auth = request.env['omniauth.auth']
    user = build_user_from_auth(auth)
    log_in(user)
    login_success
  rescue StandardError => e
    login_failure(e)
  end

  # --- User作成まで ---
  def build_user_from_auth(auth)
    log_auth_info(auth)
    User.find_or_create_by!(line_uid: auth['uid']) do |u|
      u.name = auth.dig('info', 'name')
      u.email = nil
    end
  end

  # --- ログインセッション管理 ---
  def log_in(user)
    session[:user_id] = user.id
  end

  # --- 成功/失敗のレスポンス分離 ---
  def login_success
    redirect_to albums_path, notice: t('flash.login.success')
  end

  def login_failure(err)
    Rails.logger.error "LINE Login Error: #{err.message}"
    redirect_to root_path, alert: t('flash.login.failure')
  end

  # --- ログ出力 ---
  def log_auth_info(auth)
    Rails.logger.info "AUTH DATA: #{auth.inspect}"
    Rails.logger.info "LINE UID: #{auth['uid']}"
    Rails.logger.info "NAME: #{auth.dig('info', 'name')}"
    Rails.logger.info "IMAGE: #{auth.dig('info', 'image')}"
  end
end
