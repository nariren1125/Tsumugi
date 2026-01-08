class FamilyGroupsController < ApplicationController
  # ===== 共通設定 =====
  # ログイン必須
  before_action :require_login

  # edit / update で使用する家族グループを事前にセット
  before_action :set_family_group, only: %i[edit update]

  # ===== 設定画面 =====

  # 家族設定画面
  # ・所属しているグループ一覧
  # ・現在選択中のグループ
  # ・選択中グループのメンバー一覧
  def settings
    @family_groups = current_user.family_groups
    @family_group  = current_family_group
    @family_member = family_members

    render 'family_settings/settings'
  end

  # ===== 新規作成 =====

  # 家族グループ新規作成画面
  def new
    @family_group = FamilyGroup.new
  end

  # ===== 編集 =====

  # 家族グループ編集画面（家族名変更など）
  def edit; end

  # 家族グループ新規作成
  # 作成後は自動的にそのグループへ参加し、選択中グループにする
  def create
    @family_group = FamilyGroup.new(family_group_create_params)

    if @family_group.save
      create_membership_and_select!(@family_group)
      redirect_to family_settings_path, notice: t('flash.family_group.create.success')
    else
      flash.now[:alert] = t('flash.family_group.create.failure')
      render :new, status: :unprocessable_entity
    end
  end

  # 家族グループ更新
  def update
    if @family_group.update(family_group_params)
      redirect_to family_settings_path, notice: t('flash.family_group.update.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # ===== グループ切替 =====

  # 選択中の家族グループを切り替える
  # session[:current_family_group_id] を更新することで
  # アルバム・家族メンバー・思い出の表示が切り替わる
  def switch
    family_group = current_user.family_groups.find(params[:family_group_id])
    session[:current_family_group_id] = family_group.id
    redirect_to family_settings_path, notice: t('flash.family_group.switch.success')
  end

  private

  # ===== before_action =====

  # 編集・更新対象の家族グループをセット
  # 現在選択中のグループのみを操作対象とする
  def set_family_group
    @family_group = current_family_group
  end

  # ===== 表示用データ =====

  # 選択中グループのメンバー一覧を返す
  # membership も eager load して、role 参照時の N+1 を防ぐ
  def family_members
    return [] unless @family_group

    @family_group.users.includes(:family_group_memberships)
  end

  # ===== 内部処理 =====

  # 新規作成した家族グループに参加し、
  # そのグループを「選択中グループ」に設定する
  def create_membership_and_select!(family_group)
    current_user.family_group_memberships.find_or_create_by!(family_group: family_group)
    session[:current_family_group_id] ||= family_group.id
  end

  # ===== Strong Parameters =====

  # 家族グループ作成用パラメータ
  # （現状は name のみ）
  def family_group_create_params
    params.require(:family_group).permit(:name)
  end

  # 家族グループ更新用パラメータ
  # （将来的に description 等を追加可能）
  def family_group_params
    params.require(:family_group).permit(:name, :description)
  end
end
