class SessionsController < ApplicationController
  # ============================================
  # LINEログインのコールバックは外部からPOSTされるため
  # CSRF検証をスキップ（omniauth callback対策）
  # ============================================
  skip_before_action :verify_authenticity_token, only: :create

  # ============================================
  # LINEログイン（/auth/:provider/callback）
  # ============================================
  #
  # ・omniauth の認証情報を受け取る
  # ・ユーザーを作成 or 取得
  # ・ログインセッションを作成
  # ・招待リンク経由の場合は、招待先グループへ参加させる
  #
  def create
    process_line_login
  end

  # ============================================
  # ログアウト
  # ============================================
  #
  # ・session を全削除してログアウト
  #
  def destroy
    reset_session
    redirect_to root_path, notice: t('flash.logout.success')
  end

  # ============================================
  # omniauth.auth から User を構築する
  # ============================================
  #
  # ・ログ出力で認証データを確認しやすくする（デバッグ用途）
  # ・LINE UID をキーにユーザーを取得または作成
  # ・招待リンク経由の場合、招待先グループへ membership を作成して参加
  #
  def build_user_from_auth(auth)
    log_auth_info(auth)
    user = find_or_create_user(auth)
    assign_user_to_invited_group(user)
    user
  end

  # ============================================
  # 開発用：簡易ログイン
  # ============================================
  #
  # ・開発環境でLINEログインを省略して動作確認するため
  # ・本番では routes 側で development のみ有効化している想定
  #
  def dev_login
    user = User.find(params[:id])
    session[:user_id] = user.id
    redirect_to root_path, notice: "開発用ログイン：#{user.name}"
  end

  private

  # ============================================
  # LINEログイン処理本体（例外はまとめて捕捉）
  # ============================================
  def process_line_login
    auth = request.env['omniauth.auth']
    user = build_user_from_auth(auth)

    # ログイン状態を確立
    log_in(user)

    # 成功時の遷移先へ
    login_success
  rescue StandardError => e
    login_failure(e)
  end

  # ============================================
  # ログインセッション管理
  # ============================================
  #
  # ・ログイン状態は session[:user_id] に保持
  #
  def log_in(user)
    session[:user_id] = user.id
  end

  # ============================================
  # 成功時のレスポンス
  # ============================================
  def login_success
    notice =
      if session.delete(:invite_joined)
        t('flash.family_group.joined')
      else
        t('flash.login.success')
      end

    redirect_to albums_path, notice: notice
  end

  # ============================================
  # 失敗時のレスポンス
  # ============================================
  #
  # ・例外内容をログに出し、ユーザーには一般的なエラーメッセージのみ表示
  #
  def login_failure(err)
    Rails.logger.error "LINE Login Error: #{err.message}"
    redirect_to root_path, alert: t('flash.login.failure')
  end

  # ============================================
  # 認証情報のログ出力（デバッグ用）
  # ============================================
  #
  # ・omniauth から渡された内容を確認できるようにする
  # ・本番ログに機微情報を出したくない場合は環境で制御するのもあり
  #
  def log_auth_info(auth)
    Rails.logger.info "AUTH DATA: #{auth.inspect}"
    Rails.logger.info "LINE UID: #{auth['uid']}"
    Rails.logger.info "NAME: #{auth.dig('info', 'name')}"
    Rails.logger.info "IMAGE: #{auth.dig('info', 'image')}"
  end

  # ============================================
  # LINE UID を元にユーザーを作成 or 取得
  # ============================================
  #
  # ・LINE UID は一意なので find_or_create_by で安全に扱える
  # ・Tsumugi は email を使わない設計なので nil を明示
  #
  def find_or_create_user(auth)
    User.find_or_create_by!(line_uid: auth['uid']) do |u|
      u.name  = auth.dig('info', 'name')
      u.email = nil
    end
  end

  # ============================================
  # 招待リンク経由の参加処理（最重要）
  # ============================================
  #
  # ・InviteTokensController#show で session[:invite_family_group_id] を保存している
  # ・ログインが完了したタイミングで、そのグループへ参加させる
  #
  # 注意：
  # ・旧設計の user.family_group_id を更新するのではなく、
  #   FamilyGroupMembership を作成して参加させる（複数グループ対応）
  # ・すでに参加済みなら何もしない（find_or_create_by）
  # ・処理後は invite セッションを必ず消して再参加を防ぐ
  #
  def assign_user_to_invited_group(user)
    invite_group_id = session[:invite_family_group_id]
    return if invite_group_id.blank?

    family_group = FamilyGroup.find_by(id: invite_group_id)
    return unless family_group

    # すでに参加していなければ参加させる
    add_user_to_family_group(user, family_group)

    # ⭐ 招待されたグループを「選択中グループ」にする（UX向上）
    session[:current_family_group_id] = family_group.id

    Rails.logger.info "ユーザー#{user.id}をグループ#{family_group.id}に参加させました"

    # 招待参加フラグ（ログイン成功メッセージより優先するため）
    session[:invite_joined] = true

    # 招待リンクの処理は一度きりにする
    session.delete(:invite_family_group_id)
  end

  def add_user_to_family_group(user, family_group)
    FamilyGroupMembership.find_or_create_by!(
      user: user,
      family_group: family_group
    )
  end
end
