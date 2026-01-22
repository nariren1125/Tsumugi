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
  # 【責務】
  # ・トークンを取得して有効性を確認
  # ・有効なら session に family_group_id を保存
  # ・LINEエントリー未通過なら blocked へ
  # ・問題なければトップページへ
  #
  # ※ Rubocop Metrics/AbcSize 対策として、
  #    分岐・条件判定は private メソッドへ分離している
  #
  def show
    invite = find_valid_invite

    # 無効 or 期限切れのトークンの場合
    return redirect_invalid_token unless invite

    # 招待先の家族グループIDを session に保存
    store_family_session(invite)

    # LINEエントリーが必要な環境で、未通過の場合はブロック画面へ
    return redirect_to line_blocked_path, notice: t('invite_tokens.accepted') if require_line_entry_block?

    # すべて問題なければトップページへ
    redirect_to root_path, notice: t('invite_tokens.accepted')
  rescue StandardError => e
    # 想定外エラー時はログを出して無効トークン扱いにする
    log_show_error(e)
    redirect_invalid_token
  end

  # =========================
  # 招待リンクの発行処理
  # =========================
  #
  # ・現在選択中、または指定された家族グループに対して
  #   招待トークンを発行
  # ・LINEで送信するためのURLを生成し、LINEトーク画面へ遷移
  #
  def create
    family_group = invited_family_group

    # 招待対象のグループが取得できない場合
    return redirect_family_not_exist unless family_group

    # 対象グループに紐づく招待トークンを作成
    invite = family_group.invite_tokens.create!

    # 招待URLを生成
    invite_url_full = build_invite_url(invite)

    # ログ出力
    Rails.logger.info("[InviteTokens#create] invite_url=#{invite_url_full}")

    # LINE用メッセージを生成（URLエンコード必須）
    message = build_line_message(invite_url_full)

    # LINEのトーク画面へ遷移
    redirect_to "https://line.me/R/msg/text/?#{message}", allow_other_host: true
  end

  private

  # =========================
  # 有効な招待トークンを取得
  # =========================
  #
  # ・token が一致
  # ・スコープ valid（期限切れ・無効を除外）
  #
  def find_valid_invite
    InviteToken.valid.find_by(token: params[:token])
  end

  # =========================
  # LINEエントリーが必要か判定
  # =========================
  #
  # ・local 環境では常にスキップ
  # ・本番 / staging では session[:line_entry_verified] が必須
  #
  def require_line_entry_block?
    !Rails.env.local? && !session[:line_entry_verified]
  end

  # =========================
  # show アクションの例外ログ出力
  # =========================
  #
  # ・ユーザーには詳細を見せず
  # ・ログのみで原因追跡できるようにする
  #
  def log_show_error(error)
    Rails.logger.error("[InviteTokens#show] #{error.class}: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n")) if error.backtrace
  end

  # =========================
  # 招待対象の家族グループを決定
  # =========================
  #
  # 優先順位：
  # 1. params[:family_group_id] があればそれを使用（※所属チェック必須）
  # 2. なければ current_family_group
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
  # ・ログイン後に参加処理を行うための一時保存
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
    invite_url(
      token: invite.token,
      host: ENV.fetch('APP_HOST', 'tumugi.app'),
      protocol: 'https'
    )
  end

  # =========================
  # LINE送信用メッセージ生成
  # =========================
  #
  # ・改行を含むため URLエンコード必須
  #
  def build_line_message(invite_url_full)
    text = <<~TEXT
      Tsumugi（つむぎ）からの招待です🧶

      このリンクを開くと、
      家族グループに参加できます。

      はじめての方は、
      Tsumugi公式LINEアカウントを
      追加してからご利用ください 🐿️

      #{invite_url_full}
    TEXT

    ERB::Util.url_encode(text)
  end
end
