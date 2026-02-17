module CommentsHelper
  def can_delete_comment?(post:, comment:)
    comment.user == current_user || post.user == current_user
  end
end
