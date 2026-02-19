# app/controllers/post_likes_controller.rb
class PostLikesController < ApplicationController
  # いいねを作成するアクション
  def create
    @post = Post.find(params[:post_id])
    
    # current_userに紐づく形で、この投稿へのいいねを作成
    @post_like = current_user.post_likes.new(post_id: @post.id)

    if @post_like.save
      # 成功したら元の画面（投稿一覧など）に戻る
      redirect_back(fallback_location: root_path)
    else
      # 失敗時（すでにいいねしている場合など）も元の画面に戻る
      redirect_back(fallback_location: root_path, alert: 'いいねできませんでした')
    end
  end

  # いいねを解除するアクション
  def destroy
    @post = Post.find(params[:post_id])
    
    # current_userがこの投稿にしたいいねを探す
    @post_like = current_user.post_likes.find_by(post_id: @post.id)
    
    # 存在すれば削除する
    @post_like.destroy if @post_like

    # 元の画面に戻る
    redirect_back(fallback_location: root_path)
  end
end