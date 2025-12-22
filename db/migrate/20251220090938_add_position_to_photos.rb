class AddPositionToPhotos < ActiveRecord::Migration[7.2]
  def change
    add_column :photos, :position, :integer
  end
end
