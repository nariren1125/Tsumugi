class CreatePersonTags < ActiveRecord::Migration[7.2]
  def change
    create_table :person_tags do |t|
      t.references :family_group, null: false, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end

    add_index :person_tags, [:family_group_id, :normalized_name], unique: true
  end
end
