class FamilyGroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :family_group

  has_many :person_tags, dependent: :destroy

  enum :role, { father: 0, mother: 1, other: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :family_group_id }

  # 思い出のタグ項目へのメンバー追加後処理
  after_create :ensure_person_tag_for_user
  # 権限変更ガード
  before_update :prevent_admin_removal_if_last_admin

  # 削除ガード（※グループ削除時は除外）
  before_destroy :prevent_destroy_if_last_admin, unless: :destroyed_by_family_group?

  # enumの値を日本語で返す
  def role_i18n
    I18n.t("activerecord.attributes.user.roles.#{role}")
  end

  # 役割の選択肢を取得
  def self.role_options
    roles.keys.map { |r| [I18n.t("activerecord.attributes.user.roles.#{r}"), r] }
  end

  # 管理者かどうか
  def admin?
    is_admin
  end

  private

  # ===== 削除ガード =====
  def prevent_destroy_if_last_admin
    return unless family_group.last_admin_membership?(self)

    errors.add(:base, '管理者が1人しかいないため削除できません')
    throw(:abort)
  end

  # ===== 権限変更ガード =====
  def prevent_admin_removal_if_last_admin
    return unless is_admin_changed?
    return unless is_admin_was == true && is_admin == false
    return unless family_group.last_admin_membership?(self)

    errors.add(:base, '管理者が1人しかいないため権限を外せません')
    throw(:abort)
  end

  # ===== タグ項目にメンバー追加後処理 =====
  def ensure_person_tag_for_user
    family_group.person_tags.find_or_create_by!(name: user.name)
  end

  # ===== グループ削除に伴う dependent: :destroy 判定 =====
  def destroyed_by_family_group?
    destroyed_by_association&.name == :family_group_memberships
  end
end
