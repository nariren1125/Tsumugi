module ImageHelper
  def cdn_image_path(blob, variant: nil)
    return '' unless blob.attached?

    if Rails.env.production?
      key = variant ? blob.variant(variant).processed.key : blob.key
      "https://d47gzlc2fllgd.cloudfront.net/rails/active_storage/blobs/#{key}"
    else
      url_for(variant ? blob.variant(variant) : blob)
    end
  end
end
