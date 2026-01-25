class FamilyGroup < ApplicationRecord
  # 関連付け
  has_many :children, dependent: :destroy
  has_many :invite_tokens, dependent: :destroy

  has_many :family_group_memberships, dependent: :destroy
  has_many :users, through: :family_group_memberships

  has_many :albums, dependent: :destroy
  has_many :posts, through: :albums

  has_many :person_tags, dependent: :destroy

  # 旧（users.family_group_id）
  has_many :legacy_users,
           class_name: 'User',
           dependent: :nullify

  # バリデーション:グループ名は必須
  validates :name, presence: true, length: { maximum: 50 }

  # 管理者の人数をカウントするメソッド
  def admin_count
    family_group_memberships.where(is_admin: true).count
  end

  # 管理者が1人だけかどうかを確認するメソッド
  def only_one_admin?
    family_group_memberships.where(is_admin: true).one?
  end

  # 他メンバー（自分以外）が存在するか
  def other_members_exist?(user)
    family_group_memberships.where.not(user_id: user.id).exists?
  end

  # 指定したメンバーシップが最後の管理者かどうかを確認するメソッド
  def last_admin_membership?(membership)
    return false unless membership
    return false unless membership.family_group_id == id
    return false unless membership.is_admin?

    admin_count == 1
  end

  # ActiveAdmin / Ransack 対応（検索可能カラムの明示）
  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at] & column_names
  end
  
  # 関連で検索を許可するならここも（必要最低限）
  def self.ransackable_associations(auth_object = nil)
    %w[users posts invite_tokens children person_tags] & reflect_on_all_associations.map(&:name).map(&:to_s)
  end
end
