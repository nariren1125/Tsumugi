class FamilyGroup < ApplicationRecord
  # 関連付け
  has_many :users, dependent: :nullify # 家族削除 → ユーザーは削除しない
  has_many :children, dependent: :destroy
  has_many :invite_tokens, dependent: :destroy
  has_many :posts, through: :users

  after_create :create_default_album

  # バリデーション:グループ名は必須
  validates :name, presence: true, length: { maximum: 50 }

  private

  def create_default_album
    create_album!(name: '家族アルバム')
  end
end
