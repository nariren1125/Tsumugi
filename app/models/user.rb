class User < ApplicationRecord
  # family_groupが無いユーザーも存在する仕様
  belongs_to :family_group, optional: true

  validates :line_uid, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 50 }
end
