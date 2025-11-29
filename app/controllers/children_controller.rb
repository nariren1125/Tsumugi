class ChildrenController < ApplicationController
  before_action :require_login
  def new; end

  def create
    return redirect_no_family unless current_user.family_group

    child = build_child

    child.save ? redirect_success : redirect_failure(child)
  end

  private

  def build_child
    current_user.family_group.children.new(child_params)
  end

  def redirect_no_family
    redirect_to family_settings_path, alert: t('children.no_family')
  end

  def redirect_success
    redirect_to family_settings_path, notice: t('children.created')
  end

  def redirect_failure(child)
    flash[:errors] = child.errors.full_messages
    redirect_to family_settings_path
  end

  def child_params
    params.require(:child).permit(:name, :birth_date)
  end
end
