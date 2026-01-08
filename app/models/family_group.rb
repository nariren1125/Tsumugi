class FamilyGroup < ApplicationRecord
  # 関連付け
  has_many :children, dependent: :destroy
  has_many :invite_tokens, dependent: :destroy

  has_many :family_group_memberships, dependent: :destroy
  has_many :users, through: :family_group_memberships

  has_many :albums, dependent: :destroy
  has_many :posts, through: :albums

  # 旧（users.family_group_id）
  has_many :legacy_users,
           class_name: 'User',
           dependent: :nullify

  # バリデーション:グループ名は必須
  validates :name, presence: true, length: { maximum: 50 }

  # 管理者が1人だけかどうかを確認するメソッド
  def only_one_admin?
    family_group_memberships.where(is_admin: true).one?
  end

  # 指定したユーザーが最後の管理者かどうかを確認するメソッド
  def last_admin?(user)
    membership = family_group_memberships.find_by(user: user)
    return false unless membership&.is_admin?

    only_one_admin?
  end
end
