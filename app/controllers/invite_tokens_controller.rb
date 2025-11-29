class InviteTokensController < ApplicationController
  # 招待リンクの発行はログイン必須
  before_action :require_login, only: :create
  # 招待リンクを踏む側は未ログインの可能性があるのでスキップ
  skip_before_action :require_login, only: :show

  def show
    invite = InviteToken.valid.find_by(token: params[:token])

    return redirect_invalid_token unless invite

    store_family_session(invite)
    redirect_to root_path, notice: t('invite_tokens.accepted')
  end

  def create
    return redirect_family_not_exist unless current_user.family_group

    invite = create_invite_token
    invite_url_full = build_invite_url(invite)

    message = ERB::Util.url_encode("家族に参加してください🌿\n\n#{invite_url_full}")
    redirect_to "https://line.me/R/msg/text/?#{message}", allow_other_host: true
  end

  private

  def redirect_invalid_token
    redirect_to root_path, alert: t('invite_tokens.invalid')
  end

  def store_family_session(invite)
    session[:invite_family_group_id] = invite.family_group_id
  end

  def redirect_family_not_exist
    redirect_back fallback_location: root_path,
                  alert: t('invite_tokens.family_not_exist')
  end

  def create_invite_token
    current_user.family_group.invite_tokens.create!
  end

  def build_invite_url(invite)
    invite_url(invite.token)
  end

  def log_invite_url(url)
    Rails.logger.info "INVITE URL: #{url}"
  end

  def invite_flash(url)
    flash[:notice] = t('invite_tokens.issued')
    flash.now[:invite_url] = url
  end
end
