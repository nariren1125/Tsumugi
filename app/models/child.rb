class Child < ApplicationRecord
  belongs_to :family_group

  validates :name, presence: true
end
