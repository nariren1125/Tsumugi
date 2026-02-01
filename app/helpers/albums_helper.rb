module AlbumsHelper
  # アルバム一覧ページのヘッダタイトルを返す
  def album_index_header_title
    if current_family_group&.name.present?
      "#{current_family_group.name}のアルバム"
    else
      'アルバム'
    end
  end

  # マスキングテープのクラス一覧
  MASKING_TAPE_CLASSES = %w[
    masking-tape--amber
    masking-tape--pink
    masking-tape--mint
    masking-tape--blue
    masking-tape--lavender
    masking-tape--peach
    masking-tape--sage
    masking-tape--sky
    masking-tape--lemon
  ].freeze

  # マスキングテープのクラスをランダムに返す
  def random_masking_tape_class
    MASKING_TAPE_CLASSES.sample
  end

  # マスキングテープの回転角度をランダムに返す
  def random_tape_rotation
    rand(-15..15)
  end
end
