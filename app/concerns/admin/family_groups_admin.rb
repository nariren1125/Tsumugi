module Admin
  module FamilyGroupsAdmin
    def self.included(dsl)
      dsl.instance_eval do
        actions :index, :show, :edit, :update

        controller do
          def scoped_collection
            super.includes(:users, :albums, posts: %i[user photos])
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
            row('Users count') { |fg| fg.users.size }
            row('Posts count') { |fg| fg.posts.size }
            row :created_at
            row :updated_at
          end

          panel 'Users in this Family Group' do
            if resource.users.any?
              table_for resource.users do
                column :id
                column :name
                column :email
                column :line_uid
                column :role
                column :created_at
              end
            else
              para 'No users'
            end
          end

          panel 'Posts in this Family Group' do
            posts = resource.posts

            if posts.any?
              table_for posts.order(id: :desc) do
                column :id do |post|
                  # Posts の ActiveAdmin があれば詳細へ遷移（無ければID表示だけ）
                  if respond_to?(:admin_post_path)
                    link_to post.id, admin_post_path(post)
                  else
                    post.id
                  end
                end

                column :status
                column :photo_date
                column :title
                column('Album') { |post| post.album&.title }
                column('User')  { |post| post.user&.name }
                column('Photos') { |post| post.photos.length }
                column :created_at
              end
            else
              para 'No posts'
            end
          end
        end
      end
    end
  end
end
