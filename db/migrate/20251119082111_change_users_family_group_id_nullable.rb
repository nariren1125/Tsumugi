class ChangeUsersFamilyGroupIdNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :family_group_id, true
  end
end
