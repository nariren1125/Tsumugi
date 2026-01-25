module FamilyGroupsAdmin
  def self.included(dsl)
    dsl.instance_eval do
      actions :index, :show, :edit, :update

      controller do
        def scoped_collection
          super.includes(:users, :albums, :posts)
        end
      end

      permit_params :name

      index do
        selectable_column
        id_column
        column :name
        column('Users') { |fg| fg.users.size }
        column('Posts') { |fg| fg.posts.size }
        column :created_at
        actions
      end

      filter :id
      filter :name
      filter :created_at

      show do
        attributes_table do
          row :id
          row :name
          row('Users') { |fg| fg.users.size }
          row('Posts') { |fg| fg.posts.size }
          row :created_at
          row :updated_at
        end
      end
    end
  end
end
