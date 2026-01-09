
class FamilySettings::AdminMembersController < ApplicationController
  before_action :require_login # あなたのアプリに合わせて（authenticate_user! 等）
  before_action :require_admin!

  def index
    # まずは遷移確認だけ。あとで一覧取得を足す
    # @memberships = current_family_group.family_group_memberships.includes(:user)
  end

  private
  
  def require_admin!
    return if current_membership&.admin?
    redirect_to family_settings_path, alert: t("flash.membership_admin_required")
  end
end