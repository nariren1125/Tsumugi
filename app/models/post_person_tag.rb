class PostPersonTag < ApplicationRecord
  belongs_to :post
  belongs_to :person_tag

  validates :post_id, uniqueness: { scope: :person_tag_id }
end
