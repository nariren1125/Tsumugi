class AddNotNullToFamilyGroupName < ActiveRecord::Migration[7.2]
  def change
    change_column_null :family_groups, :name, false
  end
end
