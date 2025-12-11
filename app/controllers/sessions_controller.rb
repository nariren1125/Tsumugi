class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    process_line_login
  end

  def destroy
    reset_session
    redirect_to root_path, notice: t('flash.logout.success')
  end

  def build_user_from_auth(auth)
    # --- ログ出力（LINEから渡された情報を確認） ---
    log_auth_info(auth)
    # --- LINE UID を元にユーザーを新規作成 or 取得 ---
    user = find_or_create_user(auth)
    # --- 招待リンク経由でアクセスしている場合、家族グループに自動参加させる ---
    assign_user_to_invited_group(user)
    user
  end

  # 開発環境用の簡易ログイン
  def dev_login
    user = User.find(params[:id])
    session[:user_id] = user.id
    redirect_to root_path, notice: "開発用ログイン：#{user.name}"
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

  def find_or_create_user(auth)
    User.find_or_create_by!(line_uid: auth['uid']) do |u|
      u.name  = auth.dig('info', 'name')
      u.email = nil
    end
  end

  def assign_user_to_invited_group(user)
    invite_group_id = session[:invite_family_group_id]
    return unless invite_group_id.present? && user.family_group.nil?

    user.update!(family_group_id: invite_group_id)
    Rails.logger.info "ユーザー#{user.id}をグループ#{invite_group_id}に追加しました"
    session.delete(:invite_family_group_id)
  end
end
