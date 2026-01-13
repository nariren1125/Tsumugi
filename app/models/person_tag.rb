class PersonTag < ApplicationRecord
  belongs_to :family_group

  has_many :post_person_tags, dependent: :destroy
  has_many :posts, through: :post_person_tags

  before_validation :set_normalized_name

  validates :name, presence: true
  validates :normalized_name, presence: true, uniqueness: { scope: :family_group_id }

  private
  def set_normalized_name
    self.normalized_name = name.to_s.strip.downcase
  end
end
