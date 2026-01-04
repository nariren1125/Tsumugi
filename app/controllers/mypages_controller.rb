class MypagesController < ApplicationController
  before_action :require_login

  def show
   # 他のメンバーのマイページも見れるようにする
    @user =
      if params[:id].present?
        current_user.family_group.users.find(params[:id])
      else
        current_user
      end

    # そのユーザーの投稿一覧を取得（photo_date優先で新しい順、未設定は最後）
    @posts = @user.posts.order(Arel.sql("photo_date IS NULL"), photo_date: :desc, created_at: :desc)

    @post_count = @posts.count
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to mypage_path, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :role)
  end
end
