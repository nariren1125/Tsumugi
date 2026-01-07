class FamilyGroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :family_group

  enum :role, { father: 0, mother: 1, other: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :family_group_id }

  # enumの値を日本語で返す
  def role_i18n
    I18n.t("activerecord.attributes.user.roles.#{role}")
  end

  # 役割の選択肢を取得
  def self.role_options
    roles.keys.map { |r| [I18n.t("activerecord.attributes.user.roles.#{r}"), r] }
  end

  # 管理者かどうかを判定
  def admin?
    is_admin
  end

end
