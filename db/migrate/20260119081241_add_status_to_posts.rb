class AddStatusToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :status, :integer, null: false, default: 1
    add_index  :posts, :status
  end
end
