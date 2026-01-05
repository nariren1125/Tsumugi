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
    @family_group = current_family_group
  end

  def create
    @family_group = FamilyGroup.new(name: params[:family_group][:name])
    if @family_group.save
      current_user.update!(family_group: @family_group)
      redirect_to family_settings_path, notice: t('flash.family_group.create.success')
    else
      flash.now[:alert] = t('flash.family_group.create.failure')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @family_group = current_family_group
    if @family_group.update(family_group_params)
      redirect_to family_settings_path, notice: "t('flash.family_group.update.success')"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def settings
    @family_groups = current_user.family_groups
    @family_group = current_family_group
    @family_member = @family_group&.users || []
  end
  
  def switch
    family_group = current_user.family_groups.find(params[:family_group_id])
    session[:current_family_group_id] = family_group.id
    redirect_to family_settings_path, notice: t('flash.family_group.switch.success')
  end

  private

  def family_group_params
    params.require(:family_group).permit(:name, :description)
  end
end
