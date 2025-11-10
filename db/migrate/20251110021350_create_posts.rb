class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :album, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :child, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.date :photo_date

      t.timestamps
    end
  end
end
