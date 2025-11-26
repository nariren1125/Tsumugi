class FamilyGroupsController < ApplicationController
  before_action :require_login

  def settings
    @family_group = current_user.family_group
  end

  def edit
    @family_group = current_user.family_group
  end

  def update
    @family_group = current_user.family_group
    if @family_group.update(family_group_params)
      redirect_to edit_family_group_path(@family_group),
                  notice: t('flash.login.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def family_group_params
    params.require(:family_group).permit(:name, :description)
  end
end
