class FamilyGroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :family_group
  
  validates :user_id, uniqueness: { scope: :family_group_id }
end
