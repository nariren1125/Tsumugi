class MypagesController < ApplicationController
  # ===== 共通設定 =====
  # ログイン必須
  before_action :require_login

  # show アクションで表示対象のユーザーを決定
  before_action :set_user, only: :show

  # ===== 表示 =====

  # マイページ / 家族メンバーの個人ページ
  # ・選択中グループに属する投稿のみを表示
  # ・年度での絞り込みに対応
  def show
    # 選択中グループ × 対象ユーザーの投稿に限定
    posts = base_posts_scope

    # 年度セレクト用の候補（photo_date があるもののみ）
    @years = available_years(posts)

    # 年度指定があれば絞り込み
    posts = filter_by_year(posts)

    # 現在選択されている年度（select表示用）
    @selected_year = params[:year].presence

    # 表示順を整えた投稿一覧
    @posts = ordered_posts(posts)

    # 投稿数（ヘッダー表示用）
    @post_count = @posts.count
  end

  # ===== 編集 =====

  # プロフィール編集画面（自分のみ）
  def edit
    @user = current_user
  end

  # プロフィール更新
  # ・User の基本情報（name）
  # ・選択中グループにおける role（membership）
  # を同時に更新する
  def update
    @user = current_user

    # User と Membership を同時に更新するためトランザクションで保護
    ActiveRecord::Base.transaction do
      update_user!
      update_membership_role_if_needed!
    end

    redirect_to mypage_path, notice: t('flash.mypage.updated')
  rescue ActiveRecord::RecordInvalid
    # どちらかの更新に失敗した場合は編集画面に戻す
    render :edit, status: :unprocessable_entity
  end

  private

  # ===== before_action =====

  # 表示対象のユーザーを決定
  # ・id があれば「同じグループ内の家族」
  # ・なければ「自分」
  def set_user
    @user = params[:id].present? ? family_member : current_user
  end

  # ===== 表示対象ユーザー取得 =====

  # 選択中の家族グループ内から、指定されたユーザーを取得
  # 他グループのユーザーを参照できないように制限
  def family_member
    current_family_group.users.find(params[:id])
  end

  # ===== 投稿取得 =====

  # 選択中グループ × 対象ユーザーの投稿に限定した基本スコープ
  # ・グループ切替時に他グループの思い出が漏れないようにする
  # ・N+1 を防ぐため photos / blob を eager load
  def base_posts_scope
    return Post.none unless current_family_group

    Post
      .joins(:album)
      .where(albums: { family_group_id: current_family_group.id })
      .where(user_id: @user.id)
      .includes(photos: { image_attachment: :blob })
  end

  # ===== 年度絞り込み =====

  # 投稿から年度（年）の候補一覧を取得
  # photo_date が設定されている投稿のみ対象
  def available_years(posts)
    posts
      .where.not(photo_date: nil)
      .distinct
      .pluck(Arel.sql('EXTRACT(YEAR FROM photo_date)'))
      .map(&:to_i)
      .sort
      .reverse
  end

  # 年度指定がある場合のみ投稿を絞り込む
  def filter_by_year(posts)
    return posts if params[:year].blank?

    posts.where(photo_date: year_range(params[:year].to_i))
  end

  # 指定した年の開始日〜終了日を返す
  def year_range(year)
    start_date = Date.new(year, 1, 1)
    start_date..start_date.end_of_year
  end

  # ===== 並び替え =====

  # 投稿の表示順を定義
  # ・photo_date あり → 新しい順
  # ・photo_date 未設定 → 最後
  def ordered_posts(posts)
    posts.order(
      Arel.sql('photo_date IS NULL'),
      photo_date: :desc,
      created_at: :desc
    )
  end

  # ===== 更新処理 =====

  # User の基本情報を更新
  def update_user!
    @user.update!(user_params)
  end

  # role が送信されている場合のみ、
  # 選択中グループにおける membership の role を更新
  def update_membership_role_if_needed!
    return if params[:user][:role].blank?

    membership = @user.family_group_memberships.find_by!(
      family_group_id: current_family_group.id
    )
    membership.update!(role: params[:user][:role])
  end

  # ===== Strong Parameters =====

  # User 本体で更新可能な属性
  def user_params
    params.require(:user).permit(:name)
  end
end
