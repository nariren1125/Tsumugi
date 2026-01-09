# frozen_string_literal: true

module FamilySettings
  class AdminMembersController < ApplicationController
    # =====================================
    # before_action
    # =====================================
    before_action :require_login
    before_action :require_admin!
    before_action :set_family_group
    before_action :set_membership, only: %i[edit update destroy]

    # =====================================
    # 一覧
    # 管理対象となる家族メンバー一覧を表示
    # =====================================
    def index
      @memberships = memberships_for_index
    end

    # =====================================
    # 詳細
    # 権限変更・削除画面
    # =====================================
    def edit; end

    # =====================================
    # 更新
    # 役割・管理者権限の変更
    # =====================================
    def update
      return if redirect_if_update_blocked?

      if @membership.update(membership_params)
        redirect_to family_settings_admin_members_path,
                    notice: t('flash.membership.admin_changed.success')
      else
        flash.now[:alert] = t('flash.membership.admin_changed.failure')
        render :edit
      end
    end

    # =====================================
    # 削除
    # メンバーをグループから削除
    # =====================================
    def destroy
      return if redirect_if_destroy_blocked?

      if @membership.destroy
        redirect_to family_settings_admin_members_path,
                    notice: t('flash.member.remove.success')
      else
        redirect_to_edit_with_alert(t('flash.member.remove.failure'))
      end
    end

    private

    # =====================================
    # 一覧用の取得（N+1 対策）
    # =====================================
    def memberships_for_index
      @family_group.family_group_memberships.includes(:user).order(:created_at)
    end

    # =====================================
    # グループ取得
    # =====================================
    def set_family_group
      @family_group = current_family_group
      return if @family_group

      redirect_to family_settings_path, alert: t('flash.authorization.failure')
    end

    # =====================================
    # membership 取得
    # current_family_group でスコープ制限（直叩き対策）
    # =====================================
    def set_membership
      @membership = @family_group.family_group_memberships.find(params[:id])
    end

    # =====================================
    # 管理者チェック
    # =====================================
    def require_admin!
      return if current_membership&.admin?

      redirect_to family_settings_path, alert: t('flash.membership.admin.requested')
    end

    # =====================================
    # Strong Parameters
    # 自分自身の場合 is_admin は変更不可
    # =====================================
    def membership_params
      permitted = %i[role]
      permitted << :is_admin unless editing_self?

      params.require(:family_group_membership).permit(permitted)
    end

    # =====================================
    # 判定系
    # =====================================
    def editing_self?
      @membership.user_id == current_user.id
    end

    # フォーム上で is_admin を外そうとしているか？
    def removing_admin?
      admin_param = params.dig(:family_group_membership, :is_admin)
      admin_param.to_s == '0' && @membership.is_admin?
    end

    def last_admin?
      @family_group.last_admin_membership?(@membership)
    end

    # =====================================
    # update のブロック条件
    # =====================================
    def redirect_if_update_blocked?
      redirect_if_self_admin_removal? || redirect_if_last_admin_removal?
    end

    def redirect_if_self_admin_removal?
      return false unless editing_self? && removing_admin?

      redirect_to_edit_with_alert(t('flash.membership.admin_changed.failure'))
      true
    end

    def redirect_if_last_admin_removal?
      return false unless removing_admin? && last_admin?

      redirect_to_edit_with_alert(t('flash.family_group.last_admin_cannot_leave'))
      true
    end

    # =====================================
    # destroy のブロック条件
    # =====================================
    def redirect_if_destroy_blocked?
      redirect_if_self_destroy? || redirect_if_last_admin_destroy?
    end

    def redirect_if_self_destroy?
      return false unless editing_self?

      redirect_to_edit_with_alert(t('flash.member.remove.failure'))
      true
    end

    def redirect_if_last_admin_destroy?
      return false unless last_admin?

      redirect_to_edit_with_alert(t('flash.family_group.last_admin_cannot_leave'))
      true
    end

    # =====================================
    # 共通リダイレクト
    # =====================================
    def redirect_to_edit_with_alert(message)
      redirect_to edit_family_settings_admin_member_path(@membership), alert: message
    end
  end
end
