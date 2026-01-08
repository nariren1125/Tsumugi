module FamilySettings
  class MembersController < ApplicationController
    # ログイン必須
    before_action :require_login

    # ============================
    # 家族一覧 編集画面
    # ============================
    def edit
      @family_group = current_family_group
      @members = members_for(@family_group)
    end

    # ============================
    # グループからの退出
    # ============================
    def leave
      family_group = current_family_group
      return redirect_no_family_group unless family_group

      membership = current_membership
      return redirect_no_membership unless membership

      return block_last_admin_leave(family_group) if last_admin?(family_group)

      membership.destroy!
      reset_current_family_group!

      redirect_to family_settings_path, notice: t('flash.family_group.leave.success')
    end

    private

    # ============================
    # 表示用：メンバー一覧
    # ============================
    def members_for(family_group)
      return [] unless family_group

      family_group.users.includes(:family_group_memberships)
    end

    # ============================
    # 最後の管理者か？
    # ============================
    def last_admin?(family_group)
      family_group.last_admin?(current_user)
    end

    # ============================
    # 最後の管理者の退出をブロック
    # ============================
    def block_last_admin_leave(_family_group)
      redirect_to family_settings_members_edit_path,
                  alert: t('flash.family_group.last_admin_cannot_leave')
    end

    # ============================
    # グループ未選択
    # ============================
    def redirect_no_family_group
      redirect_to family_settings_path,
                  alert: t('flash.family_group.leave.no_family_group')
    end

    # ============================
    # membership 不在
    # ============================
    def redirect_no_membership
      redirect_to family_settings_path,
                  alert: t('flash.family_group.leave.no_membership')
    end

    # ============================
    # 退出後の current_family_group 再設定
    # ============================
    def reset_current_family_group!
      next_group = current_user.family_groups.first
      next_group ? select_family_group(next_group) : clear_selected_family_group
    end

    def select_family_group(group)
      session[:current_family_group_id] = group.id
    end

    def clear_selected_family_group
      session.delete(:current_family_group_id)
    end
  end
end
