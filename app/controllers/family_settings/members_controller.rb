module FamilySettings
  class MembersController < ApplicationController
    before_action :require_login

    def edit
      @family_group = current_family_group
      @members = @family_group ? @family_group.users.includes(:family_group_memberships) : []
    end

    # グループからの退出
    def leave
      membership = current_membership
      return redirect_no_membership unless membership
  
      membership.destroy!
  
      reset_current_family_group
  
      redirect_to family_settings_path,
                  notice: t("flash.family_group.leave.success")
    end

    private

    #  退出しようとしているグループのメンバーシップを取得
    def redirect_no_membership
      redirect_to family_settings_path,
                  alert: t("flash.family_group.leave.no_membership")
    end

    # 退出後の current_family_group 調整
    def reset_current_family_group
      next_group = current_user.family_groups.first

      if next_group
        session[:current_family_group_id] = next_group.id
      else
        session.delete(:current_family_group_id)
      end
    end
  end
end
