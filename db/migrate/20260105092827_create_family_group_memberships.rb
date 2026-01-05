class CreateFamilyGroupMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :family_group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :family_group, null: false, foreign_key: true
      t.timestamps
    end

    add_index :family_group_memberships, [:user_id, :family_group_id], unique: true
  end
end
