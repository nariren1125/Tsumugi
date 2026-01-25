ActiveAdmin.register FamilyGroup do
  actions :index, :show, :edit, :update

  permit_params(*(%i[name] & FamilyGroup.column_names.map(&:to_sym)))

  index do
    selectable_column
    id_column
    column(:name) if FamilyGroup.column_names.include?("name")
    column :created_at
    actions
  end

  filter :id
  filter(:name) if FamilyGroup.column_names.include?("name")
  filter :created_at
  filter :updated_at
end
