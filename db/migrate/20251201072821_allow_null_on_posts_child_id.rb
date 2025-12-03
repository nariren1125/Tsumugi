class AllowNullOnPostsChildId < ActiveRecord::Migration[7.2]
  def change
    change_column_null :posts, :child_id, true
  end
end
