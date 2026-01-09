module FamilySettings
  class GroupsController < ApplicationController
    before_action :require_login
    before_action :require_admin!

    def edit
      # まずは遷移確認だけ。あとで @family_group = current_family_group
    end

    private

    def require_admin!
      return if current_membership&.admin?

      redirect_to family_settings_path, alert: t('flash.membership_admin_required')
    end
  end
end
