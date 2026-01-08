module FamilySettings
  class MembersController < ApplicationController
    # ============================================
    # 共通設定
    # ============================================

    # ログイン必須
    before_action :require_login

    # ============================================
    # 家族一覧 編集画面
    # ============================================
    #
    # ・現在選択中の家族グループに属するメンバーを一覧表示
    # ・招待 / 退出 UI を提供
    #
    def edit
      @family_group = current_family_group

      # グループ未選択時は空配列（ビューで安全に扱うため）
      @members =
        if @family_group
          @family_group.users.includes(:family_group_memberships)
        else
          []
        end
    end

    # ============================================
    # グループからの退出処理
    # ============================================
    #
    # ・現在選択中の家族グループから退出する
    # ・管理者が最後の1人の場合は退出不可
    # ・退出後は次のグループを自動選択（UX向上）
    #
    def leave
      family_group = current_family_group
      return redirect_no_family_group unless family_group

      # 現在選択中グループにおける membership を取得
      membership = current_membership
      return redirect_no_membership unless membership

      # --------------------------------------------
      # 管理者が最後の1人の場合は退出させない
      # --------------------------------------------
      if family_group.last_admin?(current_user)
        return redirect_to family_settings_members_edit_path,
                           alert: t("flash.family_group.last_admin_cannot_leave")
      end

      # --------------------------------------------
      # 退出処理（membership を削除）
      # --------------------------------------------
      membership.destroy!

      # 退出後の current_family_group を再設定
      reset_current_family_group

      redirect_to family_settings_path,
                  notice: t("flash.family_group.leave.success")
    end

    private

    # ============================================
    # グループが選択されていない場合のガード
    # ============================================
    def redirect_no_family_group
      redirect_to family_settings_path,
                  alert: t("flash.family_group.leave.no_family_group")
    end

    # ============================================
    # membership が存在しない場合のガード
    # ============================================
    #
    # 不正なURL直叩きや、状態不整合を防ぐための保険
    #
    def redirect_no_membership
      redirect_to family_settings_path,
                  alert: t("flash.family_group.leave.no_membership")
    end

    # ============================================
    # 退出後の current_family_group 再設定
    # ============================================
    #
    # ・他に所属グループがあれば先頭を選択
    # ・なければ current_family_group をクリア
    #
    def reset_current_family_group
      next_group = current_user.family_groups.first

      if next_group
        session[:current_family_group_id] = next_group.id
      else
        session.delete(:current_family_group_id)
      end
    end
  end
end
