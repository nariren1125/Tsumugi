class ChildrenController < ApplicationController
  before_action :require_login
  before_action :set_child, only: %i[edit update destroy]

  def new
    @child = Child.new
  end

  def edit
    @child = current_user.family_group.children.find(params[:id])
  end

  def create
    return redirect_no_family unless current_user.family_group

    @child = build_child

    if @child.save
      redirect_success
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @child.update(child_params)
      redirect_to family_settings_path, notice: t('flash.children.updated')
    else
      flash.now[:alert] = @child.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @child.destroy
    redirect_to family_settings_path, notice: t('flash.children.deleted')
  end

  private

  def build_child
    current_user.family_group.children.new(child_params)
  end

  def redirect_no_family
    redirect_to family_settings_path, alert: t('flash.children.no_family')
  end

  def redirect_success
    redirect_to family_settings_path, notice: t('flash.children.created')
  end

  def set_child
    @child = current_user.family_group.children.find(params[:id])
  end

  def child_params
    params.require(:child).permit(:name, :birth_date)
  end
end
