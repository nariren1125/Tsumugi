class ApplicationController < ActionController::Base
  helper_method :current_user
  helper_method :current_family_group
  after_action :join_family_group_after_signup, if: -> { current_user.present? && session[:invite_family_group_id].present? }

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
    family_group = FamilyGroup.find_by(id: session[:invite_family_group_id])
    return unless family_group

    # すでにそのグループに所属しているなら何もしない
    already_member = current_user.family_group_memberships.exists?(family_group_id: family_group.id)
    if already_member
      session.delete(:invite_family_group_id)
      session[:current_family_group_id] ||= family_group.id
      return
    end

    # 新：membershipで参加させる
    current_user.family_group_memberships.create!(family_group: family_group)

    # 招待情報を消す
    session.delete(:invite_family_group_id)

    # 初回はこのグループを選択中にしておくと自然
    session[:current_family_group_id] ||= family_group.id
  end

  def current_family_group
    return @current_family_group if defined?(@current_family_group)
    return nil unless current_user

    # 移行期の保険：旧 family_group_id があるのに membership が無いなら作る
    if current_user.family_group_id.present?
      current_user.family_group_memberships.find_or_create_by!(family_group_id: current_user.family_group_id)
    end

    # sessionに保存されている選択中グループを優先
    if session[:current_family_group_id].present?
      @current_family_group = current_user.family_groups.find_by(id: session[:current_family_group_id])
      return @current_family_group if @current_family_group
    end

    # sessionが無い/不正な場合は、所属グループの先頭を採用
    @current_family_group = current_user.family_groups.first

    # 移行期の後方互換（旧 users.family_group_id があればfallback）
    @current_family_group ||= current_user.family_group

    # 決まったらsessionに保存（次回から安定）
    session[:current_family_group_id] = @current_family_group&.id

    @current_family_group
  end

  allow_browser versions: :modern
end
