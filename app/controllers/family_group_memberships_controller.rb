class FamilyGroupMembershipsController < ApplicationController
  before_action :set_membership
  before_action :require_admin!

  def edit
  end

  def update
    # 自分自身の is_admin を外そうとしている場合は拒否
    if @membership.user_id == current_user.id &&
      @membership.is_admin? &&
      membership_params[:is_admin] == "0"
     redirect_to edit_family_group_membership_path(@membership),
                 alert: "自分の管理者権限は外せません"
       return
     end

    # メンバー情報更新
    if @membership.update(membership_params)
      redirect_to family_settings_path, notice: "メンバー情報を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit
    end
  end

  private

  def set_membership
    @membership = FamilyGroupMembership.find(params[:id])
  end

  def require_admin!
    unless current_membership&.admin?
      redirect_to root_path, alert: "権限がありません"
    end
  end

  def membership_params
    # 自分自身のadminフラグを外せないように制御（update側でも）
    if @membership.user_id == current_user.id
      params.require(:family_group_membership).permit(:role)
    else
      params.require(:family_group_membership).permit(:role, :is_admin)
    end
  end
end
