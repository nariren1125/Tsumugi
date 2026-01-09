class FamilyGroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :family_group

  enum :role, { father: 0, mother: 1, other: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :family_group_id }

  before_update :prevent_admin_removal_if_last_admin
  before_destroy :prevent_destroy_if_last_admin

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

  private

  # 管理者一人の場合、削除を塞ぐ
  def prevent_destroy_if_last_admin
    return unless family_group.last_admin_membership?(self)

    errors.add(:base, '管理者が1人しかいないため削除できません')
    throw(:abort)
  end

  # 管理者一人の場合、権限を一般ユーザーにできない仕様とする。
  def prevent_admin_removal_if_last_admin
    return unless is_admin_changed?
    return unless is_admin_was == true && is_admin == false
    return unless family_group.last_admin_membership?(self)

    errors.add(:base, '管理者が1人しかいないため権限を外せません')
    throw(:abort)
  end
end
