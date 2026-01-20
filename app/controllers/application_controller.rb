class ApplicationController < ActionController::Base
  # LINE入場券認証を必須化
  before_action :require_line_entry

  # ===== 定数 =====
  # 公開ページのパス一覧
  PUBLIC_PATHS = [
    '/line/entry',
    '/line/blocked',
    '/about',
    '/terms',
    '/privacy',
    '/how_to_use',
    '/faq',
    '/line_unlink',
    '/contact',
    '/up',
    '/service-worker',
    '/manifest.json'
  ].freeze

  # ===== helper_method =====
  # ビューから current_user / current_family_group / current_membership / current_role を参照できるようにする
  helper_method :current_user, :current_family_group, :current_membership, :current_role

  # ===== after_action =====
  # 招待リンク経由でサインアップした直後に、招待されたグループへ membership を作成して参加させる
  after_action :join_family_group_after_signup, if: lambda {
    current_user.present? && session[:invite_family_group_id].present?
  }

  # LINEリッチメニュー経由で入場券を取得しているか確認し、未取得ならブロックページへリダイレクトする
  def require_line_entry
    return if Rails.env.local?
    return if allow_public_path?
    return if session[:line_entry_verified]

    redirect_to line_blocked_path
  end

  private

  # ===== 認証 =====

  # 現在ログイン中のユーザーを返す（session[:user_id]から取得してメモ化）
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  # ログイン必須ページ用（未ログインならトップへリダイレクト）
  def require_login
    redirect_to root_path, alert: t('flash.login.required') if current_user.blank?
  end

  # ===== 招待リンク参加処理 =====

  # 招待リンク経由でサインアップした場合に、招待された家族グループへ参加させる
  def join_family_group_after_signup
    # 招待トークンから対象グループを取得（なければ何もしない）
    family_group = invited_family_group
    return unless family_group

    # すでに参加済みならセッション整理＆選択中グループだけセットして終了
    return if already_member?(family_group)

    # 未参加なら membership を作成し、選択中グループに設定して招待セッションを消す
    create_membership_and_select!(family_group)
  end

  # ===== グループ選択 =====

  # 現在選択中の家族グループを返す（session優先 → fallback）
  def current_family_group
    return @current_family_group if defined?(@current_family_group)
    return nil unless current_user

    # 移行期の保険：旧 users.family_group_id があれば membership を補完して整合を取る
    ensure_legacy_membership!

    # sessionで選択中グループがあればそれを採用（不正ならfallback）
    @current_family_group = selected_family_group_from_session || fallback_family_group

    # 決まったら session に保存して次回以降安定させる
    session[:current_family_group_id] = @current_family_group&.id

    @current_family_group
  end

  # 選択中グループに属する投稿だけを返すスコープ（グループ切替で表示が切り替わる）
  def posts_scope
    family_group = current_family_group
    return Post.none unless family_group

    # posts → albums を介して family_group を絞る（アルバムがグループに属する前提）
    Post.joins(:album).where(albums: { family_group_id: family_group.id })
  end

  # ===== 現在の membership / role =====

  # 現在ユーザーの「選択中グループにおける membership」を返す（メモ化）
  def current_membership
    return @current_membership if defined?(@current_membership)
    return nil unless current_user && current_family_group

    @current_membership =
      current_user.family_group_memberships.find_by(family_group_id: current_family_group.id)
  end

  # 現在ユーザーの「選択中グループにおける role」を返す
  def current_role
    current_membership&.role
  end

  # ===== 以下、分割した private =====

  # 招待セッション（invite_family_group_id）から、招待対象の家族グループを取得する
  def invited_family_group
    invite_id = session[:invite_family_group_id]
    return nil if invite_id.blank?

    FamilyGroup.find_by(id: invite_id)
  end

  # すでにそのグループに参加済みなら、招待セッションを消し、選択中グループに設定して true を返す
  # 未参加なら false を返す
  def already_member?(family_group)
    return false unless current_user.family_group_memberships.exists?(family_group_id: family_group.id)

    clear_invite_session!
    select_family_group!(family_group)
    true
  end

  # 未参加ユーザーを membership で参加させ、招待セッションを消し、選択中グループに設定する
  def create_membership_and_select!(family_group)
    current_user.family_group_memberships.create!(family_group: family_group)
    clear_invite_session!
    select_family_group!(family_group)
  end

  # 招待に関するセッション情報を削除する
  def clear_invite_session!
    session.delete(:invite_family_group_id)
  end

  # そのグループを「現在選択中」にする（すでに選択中がある場合は上書きしない）
  def select_family_group!(family_group)
    session[:current_family_group_id] ||= family_group.id
  end

  # 移行期の保険：旧 users.family_group_id があるのに membership が無い場合に、membership を作成する
  def ensure_legacy_membership!
    legacy_id = current_user.family_group_id
    return if legacy_id.blank?

    current_user.family_group_memberships.find_or_create_by!(family_group_id: legacy_id)
  end

  # session[:current_family_group_id] が有効なら、そのグループを返す（無効なら nil）
  def selected_family_group_from_session
    selected_id = session[:current_family_group_id]
    return nil if selected_id.blank?

    current_user.family_groups.find_by(id: selected_id)
  end

  # session が無い/不正な場合の fallback：
  # 新しい設計（memberships経由の所属グループ）を優先し、移行期の旧 family_group を最後に参照する
  def fallback_family_group
    current_user.family_groups.first || current_user.family_group
  end

  # LINE入場券認証関連
  def allow_public_path?
    PUBLIC_PATHS.include?(request.path)
  end
end
