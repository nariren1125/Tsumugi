class CreateAlbums < ActiveRecord::Migration[7.2]
  def change
    create_table :albums do |t|
      t.references :family_group, null: false, foreign_key: true
      t.references :child, null: false, foreign_key: true
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
