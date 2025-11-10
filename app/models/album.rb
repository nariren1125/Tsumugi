class Album < ApplicationRecord
  belongs_to :family_group
  belongs_to :child
end
