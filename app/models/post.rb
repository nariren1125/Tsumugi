class Post < ApplicationRecord
  belongs_to :album
  belongs_to :user
  belongs_to :child, optional: true

  # 写真添付機能
  has_one_attached :image
  has_many :photos, dependent: :destroy

  validates :image, presence: true
  validates :content, presence: true, length: { maximum: 500 }
end
