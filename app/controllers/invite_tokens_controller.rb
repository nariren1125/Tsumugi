class InviteTokensController < ApplicationController
  # =========================
  # 招待リンクの発行側
  # =========================

  # 招待リンクの発行はログイン必須
  before_action :require_login, only: :create

  # 招待リンクを踏む側は未ログインの可能性があるためスキップ
  skip_before_action :require_login, only: :show

  # =========================
  # 招待リンクを踏んだときの処理
  # =========================
  #
  # ・トークンの有効性を確認
  # ・有効な場合は、参加対象の family_group_id を session に保存
  # ・実際のグループ参加処理は、ログイン後（SessionsController など）で行う
  #
  def show
    invite = InviteToken.valid.find_by(token: params[:token])

    # 無効 or 期限切れのトークンの場合
    return redirect_invalid_token unless invite

    # 招待先の家族グループIDをセッションに保存
    store_family_session(invite)

    # 入場券が無ければ blocked へ（sessionは保存済みなのでOK）
    unless Rails.env.local? || session[:line_entry_verified]
      return redirect_to line_blocked_path, notice: t('invite_tokens.accepted')
    end

    redirect_to root_path, notice: t('invite_tokens.accepted')
  end

  # =========================
  # 招待リンクの発行処理
  # =========================
  #
  # ・現在選択中の家族グループ（または明示されたID）に対して
  #   招待トークンを発行する
  # ・LINE用のURLを生成し、LINEトーク画面へリダイレクト
  #
  def create
    family_group = invited_family_group

    # 招待対象のグループが取得できない場合
    return redirect_family_not_exist unless family_group

    # 対象グループに紐づく招待トークンを作成
    invite = family_group.invite_tokens.create!

    # 招待URLを生成
    invite_url_full = build_invite_url(invite)

    # LINEで送信するメッセージをエンコード
    message = ERB::Util.url_encode("家族に参加してください🌿\n\n#{invite_url_full}")

    # LINEのトーク画面へ遷移
    redirect_to "https://line.me/R/msg/text/?#{message}", allow_other_host: true
  end

  private

  # =========================
  # 招待対象の家族グループを決定
  # =========================
  #
  # 優先順位：
  # 1. params[:family_group_id] があればそれを使用（※必ず所属チェック）
  # 2. なければ current_family_group（現在選択中のグループ）
  #
  # これにより、
  # ・グループ切り替え後でも正しいグループに招待できる
  # ・不正な family_group_id の指定を防止できる
  #
  def invited_family_group
    if params[:family_group_id].present?
      current_user.family_groups.find_by(id: params[:family_group_id])
    else
      current_family_group
    end
  end

  # =========================
  # 無効な招待リンクの場合
  # =========================
  def redirect_invalid_token
    redirect_to root_path, alert: t('invite_tokens.invalid')
  end

  # =========================
  # 招待された家族グループを session に保存
  # =========================
  #
  # ・ログイン後にどのグループへ参加するかを判断するために使用
  # ・実際の membership 作成は別の処理で行う
  #
  def store_family_session(invite)
    session[:invite_family_group_id] = invite.family_group_id
  end

  # =========================
  # 招待対象グループが存在しない場合
  # =========================
  def redirect_family_not_exist
    redirect_back fallback_location: root_path,
                  alert: t('invite_tokens.family_not_exist')
  end

  # =========================
  # 招待URL生成
  # =========================
  def build_invite_url(invite)
    invite_url(invite.token)
  end
end
