ActiveAdmin.register Post do
  actions :index, :show, :destroy

  index do
    selectable_column
    id_column
    column(:title) if Post.column_names.include?("title")
    column(:user_id) if Post.column_names.include?("user_id")
    column(:family_group_id) if Post.column_names.include?("family_group_id")
    column :created_at
    actions
  end

  filter :id
  filter(:title) if Post.column_names.include?("title")
  filter(:user_id) if Post.column_names.include?("user_id")
  filter(:family_group_id) if Post.column_names.include?("family_group_id")
  filter :created_at
  filter :updated_at
end
