# app/controllers/family_settings/groups_controller.rb
module FamilySettings
  class GroupsController < ApplicationController
    before_action :require_login
    before_action :require_admin!
    before_action :set_family_group

    def edit; end

    def update
      if @family_group.update(group_params)
        redirect_to family_settings_path,
                    notice: t('flash.family_group.update.success')
      else
        flash.now[:alert] = t('flash.family_group.update.failure')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      return if redirect_if_other_members_exist?
      return if redirect_if_name_not_matched?

      @family_group.destroy!
      clear_selected_family_group

      redirect_to family_settings_path,
                  notice: t('flash.family_group.delete.success')
    rescue ActiveRecord::RecordNotDestroyed
      redirect_to edit_family_settings_group_path,
                  alert: t('flash.family_group.delete.failure')
    end

    private

    def set_family_group
      @family_group = current_family_group
      return if @family_group

      redirect_to family_settings_path, alert: t('flash.family_group.leave.no_family_group')
    end

    def require_admin!
      return if current_membership&.admin?

      redirect_to family_settings_path, alert: t('flash.authorization.failure')
    end

    def group_params
      params.require(:family_group).permit(:name)
    end

    # ===== Destroy guards =====

    def redirect_if_other_members_exist?
      return false unless @family_group.other_members_exist?(current_user)

      redirect_to edit_family_settings_group_path,
                  alert: t('flash.family_group.delete.has_members')
      true
    end

    def redirect_if_name_not_matched?
      return false if confirm_name_matched?

      redirect_to edit_family_settings_group_path,
                  notice: t('flash.family_group.delete.name_mismatch')
      true
    end

    def confirm_name_matched?
      params[:confirm_name].to_s == @family_group.name.to_s
    end

    def clear_selected_family_group
      session.delete(:current_family_group_id)
    end
  end
end
