class Album < ApplicationRecord
  belongs_to :family_group
  belongs_to :child, optional: true
  belongs_to :user, optional: true

  has_many :posts, dependent: :destroy
end
