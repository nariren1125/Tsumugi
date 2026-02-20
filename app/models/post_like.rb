class PostLike < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # 変更: 1つの投稿に対して1ユーザーは1回しか「いいね」できないようにする
  validates :user_id, uniqueness: { scope: :post_id }
end
