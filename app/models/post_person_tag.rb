class PostPersonTag < ApplicationRecord
  belongs_to :post
  belongs_to :person_tag
end
