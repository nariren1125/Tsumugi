class AddUniqueIndexToUsersLineUid < ActiveRecord::Migration[7.2]
  def change
    return if index_exists?(:users, :line_uid, name: :index_users_on_line_uid)

    add_index :users, :line_uid, unique: true, name: :index_users_on_line_uid
  end
end
