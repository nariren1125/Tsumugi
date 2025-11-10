class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :line_uid
      t.string :email
      t.references :family_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
