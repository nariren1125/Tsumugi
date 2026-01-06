class AddIsAdminToFamilyGroupMemberships < ActiveRecord::Migration[7.2]
  def change
    add_column :family_group_memberships, :is_admin, :boolean, default: false, null: false
  end
end
