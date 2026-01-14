class ChangeDefaultRoleToFamilyGroupMemberships < ActiveRecord::Migration[7.2]
  def change
    change_column_default :family_group_memberships, :role, 4
  end
end
