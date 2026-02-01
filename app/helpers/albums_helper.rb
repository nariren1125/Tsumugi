module AlbumsHelper
  def album_index_header_title
    if current_family_group&.name.present?
      "#{current_family_group.name}のアルバム"
    else
      'アルバム'
    end
  end
end
