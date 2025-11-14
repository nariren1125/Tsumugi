class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :line_uid
      t.string :email
      t.references :family_group, null: true, foreign_key: true

      t.timestamps
    end

    add_index :users, :line_uid, unique: true
  end
end
