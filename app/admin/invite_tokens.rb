ActiveAdmin.register InviteToken do
  actions :index, :show, :destroy

  index do
    selectable_column
    id_column
    column(:token) if InviteToken.column_names.include?("token")
    column(:family_group_id) if InviteToken.column_names.include?("family_group_id")
    column(:expires_at) if InviteToken.column_names.include?("expires_at")
    column :created_at
    actions
  end

  filter :id
  filter(:token) if InviteToken.column_names.include?("token")
  filter(:family_group_id) if InviteToken.column_names.include?("family_group_id")
  filter(:expires_at) if InviteToken.column_names.include?("expires_at")
  filter :created_at
  filter :updated_at
end
