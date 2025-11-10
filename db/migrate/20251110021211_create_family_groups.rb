class CreateFamilyGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :family_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
