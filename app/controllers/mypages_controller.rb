class MypagesController < ApplicationController
  before_action :require_login
  before_action :set_user, only: :show

  def show
    posts = base_posts_scope

    @years = available_years(posts)
    posts = filter_by_year(posts)

    @selected_year = params[:year].presence
    @posts = ordered_posts(posts)
    @post_count = @posts.count
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to mypage_path, notice: t('flash.mypage.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # 表示ユーザーを設定
  def set_user
    @user = params[:id].present? ? family_member : current_user
  end

  # 家族グループ内から対象ユーザーを取得（権限制約）
  def family_member
    current_user.family_group.users.find(params[:id])
  end

  # 投稿の基本スコープを取得（N+1対策）
  def base_posts_scope
    @user.posts.includes(photos: { image_attachment: :blob })
  end

  # photo_date から年度候補（年）を取得
  def available_years(posts)
    posts.where.not(photo_date: nil)
         .distinct
         .pluck(Arel.sql('EXTRACT(YEAR FROM photo_date)'))
         .map(&:to_i)
         .sort
         .reverse
  end

  # 投稿を年度で絞り込み
  def filter_by_year(posts)
    return posts if params[:year].blank?

    posts.where(photo_date: year_range(params[:year].to_i))
  end

  # 年度の開始日と終了日を取得
  def year_range(year)
    start_date = Date.new(year, 1, 1)
    start_date..start_date.end_of_year
  end

  # 投稿を並び替え（photo_dateあり：新しい→古い、未設定は最後）
  def ordered_posts(posts)
    posts.order(
      Arel.sql('photo_date IS NULL'),
      photo_date: :desc,
      created_at: :desc
    )
  end

  def user_params
    params.require(:user).permit(:name, :role)
  end
end
