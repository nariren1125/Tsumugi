class CreateChildren < ActiveRecord::Migration[7.2]
  def change
    create_table :children do |t|
      t.references :family_group, null: false, foreign_key: true
      t.string :name
      t.date :birth_date

      t.timestamps
    end
  end
end
