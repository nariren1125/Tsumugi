class Post < ApplicationRecord
  belongs_to :album
  belongs_to :user
  belongs_to :child

  # 写真添付機能
  has_one_attached :image

  validates :image, presence: true
end
