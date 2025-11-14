class AddUniqueIndexToUsersLineUid < ActiveRecord::Migration[7.2]
  def change
    add_index :users, :line_uid, unique: true
  end
end
