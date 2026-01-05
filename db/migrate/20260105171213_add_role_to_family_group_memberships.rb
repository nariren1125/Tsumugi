class AddRoleToFamilyGroupMemberships < ActiveRecord::Migration[7.2]
  def change
    add_column :family_group_memberships, :role, :integer, null: false, default: 2
    add_index  :family_group_memberships, [:user_id, :family_group_id], unique: true
  end
end
