class ChangeNullOnAlbumsChildId < ActiveRecord::Migration[7.2]
  def change
    change_column_null :albums, :child_id, true
  end
end
