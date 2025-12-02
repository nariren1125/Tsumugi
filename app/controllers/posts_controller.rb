class PostsController < ApplicationController
  before_action :require_login

  def new
    @post = Post.new
    @post.photos.build  # ネストフォーム用にPhotoオブジェクトをビルド
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user  # ユーザー紐づけがある場合
    @post.album = current_user.album  # アルバムとの関連も必要に応じて

    if @post.save
      # 複数画像をループで保存
      if params[:post][:images]
        params[:post][:images].each do |image|
          @post.photos.create(image: image)
        end
      end
      redirect_to album_path(@post.album), notice: t('posts.create.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :child_id, images: [])
  end
end
