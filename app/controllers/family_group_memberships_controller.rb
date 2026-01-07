class FamilyGroupMembershipsController < ApplicationController
  # 編集対象の membership を取得
  before_action :set_membership

  # 現在のユーザーが管理者であるかチェック（管理者以外は弾く）
  before_action :require_admin!

  # 自分自身の admin 権限を外す操作を防止する
  before_action :prevent_self_admin_removal, only: :update

  def edit; end

  def update
    # メンバー情報更新に成功した場合
    if @membership.update(membership_params)
      redirect_to family_settings_path,
                  notice: t('flash.membership_admin_changed_success')
    else
      # 更新失敗時は edit に戻す
      flash.now[:alert] = t('flash.membership_admin_changed_failure')
      render :edit
    end
  end

  private

  # URLから対象の FamilyGroupMembership を特定
  def set_membership
    @membership = FamilyGroupMembership.find(params[:id])
  end

  # ログインユーザーが所属グループ内で admin でなければ root に返す
  def require_admin!
    return if current_membership&.admin?

    redirect_to root_path, alert: t('flash.membership_admin_required')
  end

  # Strong Parameter の定義
  # ※自分自身を編集している場合、admin フラグは絶対に許可しない
  def membership_params
    # 基本許可項目は role のみ
    permitted = %i[role]
    # 自分以外なら is_admin 変更を許可
    permitted << :is_admin unless editing_self?

    params.require(:family_group_membership).permit(permitted)
  end

  # 自分自身の membership を操作中かどうかの判定
  # 重複使用するためメソッド化
  def editing_self?
    @membership.user_id == current_user.id
  end

  # before_action 用
  # 自分が admin なのに is_admin を外す（0に変える）リクエストを拒否
  def prevent_self_admin_removal
    # 自分自身の membership ではないならOK
    return unless editing_self?
    # そもそも admin 権限を持っていないなら問題なし
    return unless @membership.is_admin?
    # form の値で admin が外されている判定
    return unless params.dig(:family_group_membership, :is_admin) == '0'

    # 失敗メッセージと共に編集画面へ戻す
    redirect_to edit_family_group_membership_path(@membership),
                alert: t('flash.membership_admin_changed_failure')
  end
end
