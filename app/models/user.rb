class User < ApplicationRecord
  # family_groupが無いユーザーも存在する仕様
  belongs_to :family_group, optional: true
  has_many :posts, dependent: :destroy
  has_many :family_group_memberships
  has_many :family_groups, through: :family_group_memberships

  validates :line_uid, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 50 }

  enum :role, { father: 0, mother: 1, other: 2 }

  # enumの値を日本語で返す
  def role_i18n
    I18n.t("activerecord.attributes.user.roles.#{role}")
  end

  # enumの選択肢を日本語で返す
  def self.role_options
    roles.keys.map do |key|
      [I18n.t("activerecord.attributes.user.role.#{key}"), key]
    end
  end

  # family_groupに対するmembershipを返す（グループごとに役割を切り替えるため）
  def membership_in(family_group)
    family_group_memberships.find_by(family_group_id: family_group.id)
  end

  # family_groupに対するroleの日本語表記を返す
  def role_i18n_in(family_group)
    membership_in(family_group)&.role_i18n
  end
end
