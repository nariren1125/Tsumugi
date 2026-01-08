
module FamilySettings
    class FamilyGroupsController < ApplicationController
      before_action :require_login
  
      def switch
        family_group = current_user.family_groups.find(params[:family_group_id])
        session[:current_family_group_id] = family_group.id
        redirect_to family_settings_path, notice: t("flash.family_group.switch.success")
      end
    end
  end
