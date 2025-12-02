class Photo < ApplicationRecord
  belongs_to :post
  # imagesがActive Storageで管理されるように設定
  has_many_attached :images
end
