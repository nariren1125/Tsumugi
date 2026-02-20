# app/controllers/post_likes_controller.rb
class PostLikesController < ApplicationController

  def index
    # 変更前: @posts = Post.all など
    # 変更後: includes を追加
    @posts = Post.includes(:post_likes, :comments).order(created_at: :desc)
  end

  # いいねを作成するアクション
  def create
    @post = Post.find(params[:post_id])
    
    # 変更: すでにある場合は作成せず、無い場合だけ作成する
    @post_like = current_user.post_likes.find_or_create_by(post_id: @post.id)
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  # いいねを解除するアクション
  def destroy
    @post = Post.find(params[:post_id])
    @post_like = current_user.post_likes.find_by(post_id: @post.id)
    @post_like.destroy if @post_like

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end
end