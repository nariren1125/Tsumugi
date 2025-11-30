class ApplicationController < ActionController::Base
  helper_method :current_user
  after_action :join_family_group_after_signup, if: -> { respond_to?(:user_signed_in?) && user_signed_in? }

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def require_login
    redirect_to root_path, alert: t('flash.login.required') if current_user.blank?
  end

  # サインアップ後に家族グループへ参加させる
  def join_family_group_after_signup
    return unless session[:invite_family_group_id]
    # ユーザーが招待リンクを経由していない場合には、何も処理をしない
    return if current_user.family_group_id.present?

    # current_user がどこかの家族グループに属している場合は、それ以上上書きしないで終了

    current_user.update(family_group_id: session[:invite_family_group_id])
    # invite_family_group_id を current_user.family_group_id に設定
    # 招待された家族グループに正式に参加
    session.delete(:invite_family_group_id)
    # 設定が終わったら、セッションから招待情報を削除
  end

  allow_browser versions: :modern
end
