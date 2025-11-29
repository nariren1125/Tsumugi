class FamilyGroupsController < ApplicationController
  before_action :require_login

  def settings
    @family_group = current_user.family_group
    @family_member = @family_group&.users || []
  end

  def new
    @family_group = FamilyGroup.new
  end

  def edit
    @family_group = current_user.family_group
  end

  def create
    @family_group = FamilyGroup.new(name: params[:family_group][:name])
    if @family_group.save
      current_user.update!(family_group: @family_group)
      redirect_to family_settings_path, notice: t('.success')
    else
      flash.now[:alert] = t('.failure')
      render :new, status: :unprocessable_entity
    end
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
