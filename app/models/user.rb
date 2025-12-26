class User < ApplicationRecord
  # family_groupが無いユーザーも存在する仕様
  belongs_to :family_group, optional: true
  has_many :posts, dependent: :destroy

  validates :line_uid, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 50 }

  enum role: { father: 0, mother: 1, other: 2 }

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

  # roleに応じたバッジのクラスを返す
  def role_badge_class
    case role
    when "father"
      "border-blue-400 text-blue-600 bg-blue-50"
    when "mother"
      "border-pink-400 text-pink-600 bg-pink-50"
    else
      "border-base-300 text-base-content bg-base-100"
    end
  end
end
