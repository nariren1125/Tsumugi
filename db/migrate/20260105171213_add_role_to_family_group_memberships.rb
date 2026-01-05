class AddRoleToFamilyGroupMemberships < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:family_group_memberships, :role)
      add_column :family_group_memberships, :role, :integer, null: false, default: 2
    end
  end
end
