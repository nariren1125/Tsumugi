class Post < ApplicationRecord
  belongs_to :album
  belongs_to :user
  belongs_to :child, optional: true

  # 写真との関連付け（並び順を持たせる）
  has_many :photos, -> { order(:position) }, dependent: :destroy
  # PostモデルがPhotoモデルの属性を受け入れるように設定
  accepts_nested_attributes_for :photos, allow_destroy: true

  validates :title, presence: true, length: { maximum: 100 }
  validates :content, presence: true, length: { maximum: 500 }
end
