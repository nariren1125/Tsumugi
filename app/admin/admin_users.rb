ActiveAdmin.register AdminUser do
  actions :index, :show, :edit, :update

  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at if AdminUser.column_names.include?('current_sign_in_at')
    column :sign_in_count if AdminUser.column_names.include?('sign_in_count')
    column :created_at
    actions
  end

  filter :id
  filter :email
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row :current_sign_in_at if AdminUser.column_names.include?('current_sign_in_at')
      row :sign_in_count if AdminUser.column_names.include?('sign_in_count')
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
