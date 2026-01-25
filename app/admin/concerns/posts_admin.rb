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

        column(:status)     if Post.column_names.include?('status')
        column(:photo_date) if Post.column_names.include?('photo_date')
        column(:title)      if Post.column_names.include?('title')

        column('FamilyGroup') { |post| post.album&.family_group&.name }
        column('User')       { |post| post.user&.name }

        # ✅ 画像枚数（includes(:photos) 済みなので length 推奨）
        column('Photos')     { |post| post.photos.length }

        column :created_at
        actions
      end

      filter :id
      filter(:status)     if Post.column_names.include?('status')
      filter(:title)      if Post.column_names.include?('title')
      filter(:photo_date) if Post.column_names.include?('photo_date')
      filter :user
      filter :album
      filter :created_at
      filter :updated_at

      show do
        attributes_table do
          row :id
          row(:status)     if Post.column_names.include?('status')
          row(:photo_date) if Post.column_names.include?('photo_date')
          row(:title)      if Post.column_names.include?('title')
          row(:content)    if Post.column_names.include?('content')

          row('FamilyGroup') { |post| post.album&.family_group&.name }
          row('User') { |post| post.user&.name }
          row('Photos count') { |post| post.photos.length }
        end

        panel 'Photos (Preview)' do
          if resource.photos.any?
            ul do
              resource.photos.each do |photo|
                li do
                  span "##{photo.id}  "
                  span "(pos: #{photo.try(:position)})  "

                  if photo.image.attached?
                    # vips/image_processing が揃ってる前提（いま揃えた状態）
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
