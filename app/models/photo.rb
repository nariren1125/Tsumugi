class Photo < ApplicationRecord
  belongs_to :post
  # imagesがActive Storageで管理されるように設定
  has_one_attached :image

  validate :must_have_exist

  def must_have_exist
    errors.add(:base, '写真を1枚以上アップロードしてください') unless image.attached?
  end
end
