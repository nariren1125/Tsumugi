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
end
