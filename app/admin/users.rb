ActiveAdmin.register User do
  actions :index, :show, :edit, :update

  # permit_params は「存在するカラムだけ」にしたいので、Userで判定
  permit_params(*(%i[name email line_uid family_group_id role] & User.column_names.map(&:to_sym)))

  index do
    selectable_column
    id_column
    column(:name) if User.column_names.include?("name")
    column(:email) if User.column_names.include?("email")
    column(:line_uid) if User.column_names.include?("line_uid")
    column(:family_group_id) if User.column_names.include?("family_group_id")
    column(:role) if User.column_names.include?("role")
    column :created_at
    actions
  end

  filter :id
  filter(:name) if User.column_names.include?("name")
  filter(:email) if User.column_names.include?("email")
  filter(:line_uid) if User.column_names.include?("line_uid")
  filter(:family_group_id) if User.column_names.include?("family_group_id")
  filter(:role) if User.column_names.include?("role")
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :id
      row(:name) if User.column_names.include?("name")
      row(:email) if User.column_names.include?("email")
      row(:line_uid) if User.column_names.include?("line_uid")
      row(:family_group_id) if User.column_names.include?("family_group_id")
      row(:role) if User.column_names.include?("role")
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name if User.column_names.include?("name")
      f.input :email if User.column_names.include?("email")
      f.input :line_uid if User.column_names.include?("line_uid")
      f.input :family_group_id if User.column_names.include?("family_group_id")
      f.input :role if User.column_names.include?("role")
    end
    f.actions
  end
end
