class Child < ApplicationRecord
  belongs_to :family_group

  # 追加されたときに対応する思い出のタグ項目を作成
  after_create :ensure_person_tag

  validates :name, presence: true

  private

  # ===== タグ項目に子ども追加後処理 =====
  def ensure_person_tag
    family_group.person_tags.find_or_create_by!(name: name)
  end
end
