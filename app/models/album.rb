class Album < ApplicationRecord
  belongs_to :family_group
  belongs_to :child
  belongs_to :user

  has_many :posts, dependent: :destroy
end
