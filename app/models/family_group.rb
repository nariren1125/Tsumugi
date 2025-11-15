class FamilyGroup < ApplicationRecord
  # 関連付け
  has_many :users, dependent: :nullify # 家族削除 → ユーザーは削除しない
  has_many :children, dependent: :destroy
  has_many :albums, dependent: :destroy

  # バリデーション:グループ名は必須
  validates :name, presence: true, length: { maximum: 50 }
end
