class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post

  def create
    @comment = build_comment

    if @comment.save
      respond_success(:created)
    else
      respond_failure(:create)
    end
  end

  def sheet
    @comments = @post.comments.includes(:user).order(created_at: :asc)
    @comment = @post.comments.build
  end

  def destroy
    @comment = @post.comments.find(params[:id])

    return redirect_forbidden unless owns_comment?(@comment)

    @comment.destroy
    respond_success(:deleted)
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def build_comment
    @post.comments.build(comment_params.merge(user: current_user))
  end

  def owns_comment?(comment)
    comment.user == current_user
  end

  def redirect_forbidden
    redirect_to(return_to_path, alert: t('comments.forbidden'))
  end

  def return_to_path
    params[:return_to].presence || albums_path
  end

  def respond_success(i18n_key)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to(return_to_path, notice: t("comments.#{i18n_key}")) }
    end
  end

  def respond_failure(view_name)
    respond_to do |format|
      format.turbo_stream { render view_name, status: :unprocessable_entity }
      format.html { redirect_to(return_to_path, alert: @comment.errors.full_messages.first) }
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
