class User < ApplicationRecord
  # 移行期の後方互換（あとで消す予定）
  belongs_to :family_group, optional: true

  has_many :posts, dependent: :destroy
  has_many :family_group_memberships, dependent: :destroy
  has_many :family_groups, through: :family_group_memberships
  has_many :comments, dependent: :destroy

  validates :line_uid, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 50 }

  # 役割の「選択肢」提供のためだけに残す（users.roleは今後使わない）
  enum :role, { father: 0, mother: 1, other: 2 }

  # enumの選択肢を日本語で返す
  def self.role_options
    roles.keys.map do |key|
      [I18n.t("activerecord.attributes.user.roles.#{key}"), key]
    end
  end

  # 指定した family_group における membership を返す（グループごとに役割を切り替えるため）
  def membership_in(family_group)
    return nil unless family_group

    family_group_memberships.find { |m| m.family_group_id == family_group.id } ||
      family_group_memberships.find_by(family_group_id: family_group.id)
  end

  # family_groupに対するroleの日本語表記を返す
  def role_i18n_in(family_group)
    membership_in(family_group)&.role_i18n
  end

  # ActiveAdmin / Ransack 対応（検索可能カラムの明示）
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      name
      email
      line_uid
      family_group_id
      role
      created_at
      updated_at
    ]
  end

  # 関連で検索を許可するならここも（必要最低限）
  def self.ransackable_associations(_auth_object = nil)
    %w[family_group]
  end
end
