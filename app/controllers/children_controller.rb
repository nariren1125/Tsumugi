class ChildrenController < ApplicationController
  # ============================================
  # 共通設定
  # ============================================

  # ログイン必須
  before_action :require_login

  # 編集・更新・削除時に対象の子どもを取得
  before_action :set_child, only: %i[edit update destroy]

  # ============================================
  # 新規作成
  # ============================================

  # 子ども追加画面
  def new
    # フォーム用の空オブジェクト
    @child = Child.new
  end

  # ============================================
  # 編集
  # ============================================

  # 子ども編集画面
  # set_child により、選択中グループに属する子どものみ編集可能
  def edit; end

  # ============================================
  # 作成
  # ============================================

  # 子ども作成処理
  def create
    # 家族グループが選択されていない場合は作成不可
    return redirect_no_family unless current_family_group

    # 選択中グループに紐づく子どもを生成
    @child = build_child

    if @child.save
      redirect_success
    else
      # バリデーションエラー時は入力内容を保持して再表示
      render :new, status: :unprocessable_entity
    end
  end

  # ============================================
  # 更新
  # ============================================

  # 子ども情報の更新
  def update
    if @child.update(child_params)
      redirect_to family_settings_path, notice: t('flash.children.updated')
    else
      flash.now[:alert] = @child.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  # ============================================
  # 削除
  # ============================================

  # 子どもの削除
  def destroy
    @child.destroy
    redirect_to family_settings_path, notice: t('flash.children.deleted')
  end

  private

  # ============================================
  # before_action
  # ============================================

  # 選択中の家族グループに属する子どものみ取得
  #
  # ・他グループの子どもを編集・削除できないように制御
  # ・グループ切り替え機能前提の重要なガード
  #
  def set_child
    @child = current_family_group.children.find(params[:id])
  end

  # ============================================
  # 内部処理
  # ============================================

  # 選択中の家族グループに紐づく子どもを生成
  #
  # ・current_user.family_group は使用しない
  # ・必ず current_family_group 経由で作成する
  #
  def build_child
    current_family_group.children.new(child_params)
  end

  # ============================================
  # リダイレクト処理
  # ============================================

  # 家族グループ未選択時のエラー誘導
  def redirect_no_family
    redirect_to family_settings_path, alert: t('flash.children.no_family')
  end

  # 作成成功時のリダイレクト
  def redirect_success
    redirect_to family_settings_path, notice: t('flash.children.created')
  end

  # ============================================
  # Strong Parameters
  # ============================================

  # 子ども作成・更新時に許可する属性
  def child_params
    params.require(:child).permit(:name, :birth_date)
  end
end
