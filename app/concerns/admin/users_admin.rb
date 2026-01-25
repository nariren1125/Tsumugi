module Admin
  module UsersAdmin
    def self.included(dsl)
      dsl.instance_eval do
        actions :index, :show, :edit, :update

        permit_params :name, :email, :line_uid, :family_group_id, :role

        controller do
          def scoped_collection
            super.includes(:family_group, :family_groups)
          end
        end

        index do
          selectable_column
          id_column
          column :name
          column :email
          column :line_uid
          column('Legacy FamilyGroup') { |user| user.family_group&.name }
          column('Groups') { |user| user.family_groups.size }
          column :created_at
          actions
        end

        filter :id
        filter :name
        filter :email
        filter :line_uid
        filter :family_group, label: 'Legacy FamilyGroup'
        filter :created_at
        filter :updated_at

        show do
          attributes_table do
            row :id
            row :name
            row :email
            row :line_uid
            row('Legacy FamilyGroup') { |user| user.family_group&.name }
            row('FamilyGroups (current memberships)') { |user| user.family_groups.map(&:name).join(', ') }
            row :created_at
            row :updated_at
          end
        end

        form do |f|
          f.inputs do
            f.input :name
            f.input :email
            f.input :line_uid
            f.input :family_group_id
            f.input :role
          end
          f.actions
        end
      end
    end
  end
end
