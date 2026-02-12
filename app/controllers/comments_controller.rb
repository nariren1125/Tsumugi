class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_back fallback_location: albums_path, notice: t('comments.created')
    else
      redirect_back fallback_location: albums_path, alert: @comment.errors.full_messages.first
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    unless @comment.user == current_user
      return redirect_back(fallback_location: albums_path,
                           alert: t('comments.forbidden'))
    end

    @comment.destroy
    redirect_back fallback_location: albums_path, notice: t('comments.deleted')
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
