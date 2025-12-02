class FamilyGroup < ApplicationRecord
  # 関連付け
  has_many :users, dependent: :nullify # 家族削除 → ユーザーは削除しない
  has_many :children, dependent: :destroy
  has_one :album, dependent: :destroy
  has_many :invite_tokens, dependent: :destroy

  after_create :create_album

  # バリデーション:グループ名は必須
  validates :name, presence: true, length: { maximum: 50 }

  private

  def create_album
    Album.create!(family_group: self, name: "#{self.id}のアルバム")
  end
end
