class FamilyGroup < ApplicationRecord
  # 関連付け
  has_many :children, dependent: :destroy
  has_many :invite_tokens, dependent: :destroy

  has_many :family_group_memberships, dependent: :destroy
  has_many :users, through: :family_group_memberships

  has_many :albums, dependent: :destroy
  has_many :posts, through: :albums

  # 旧（users.family_group_id）
  has_many :legacy_users, class_name: "User", foreign_key: :family_group_id

  # バリデーション:グループ名は必須
  validates :name, presence: true, length: { maximum: 50 }
end
