class CreatePhotos < ActiveRecord::Migration[7.2]
  def change
    create_table :photos do |t|
      t.references :post, null: false, foreign_key: true
      t.string :image_url

      t.timestamps
    end
  end
end
