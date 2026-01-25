module Admin
  module PostsAdmin
    def self.included(dsl)
      dsl.instance_eval do
        actions :index, :show, :destroy

        controller do
          def scoped_collection
            super.includes(:user, { album: :family_group }, :photos)
          end
        end

        index do
          selectable_column
          id_column

          # ✅ DBが無くても落ちない（column_names を使わない）
          column :status
          column :photo_date
          column :title

          column('FamilyGroup') { |post| post.album&.family_group&.name }
          column('User')       { |post| post.user&.name }

          column('Photos')     { |post| post.photos.length }

          column :created_at
          actions
        end

        filter :id
        filter :status
        filter :title
        filter :photo_date
        filter :user
        filter :album
        filter :created_at
        filter :updated_at

        show do
          attributes_table do
            row :id
            row :status
            row :photo_date
            row :title
            row :content

            row('FamilyGroup') { |post| post.album&.family_group&.name }
            row('User') { |post| post.user&.name }
            row('Photos count') { |post| post.photos.length }
          end

          panel 'Photos (Preview)' do
            if resource.photos.loaded? ? resource.photos.any? : resource.photos.exists?
              ul do
                resource.photos.each do |photo|
                  li do
                    span "##{photo.id}  "
                    span "(pos: #{photo.try(:position)})  "

                    if photo.image.attached?
                      thumb = photo.image.variant(resize_to_limit: [240, 240])
                      span helpers.image_tag(helpers.url_for(thumb), size: '240x240')
                    else
                      span '※ 画像未添付'
                    end
                  end
                end
              end
            else
              para 'No photos'
            end
          end
        end
      end
    end
  end
end
