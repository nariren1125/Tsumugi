module ApplicationHelper
  # 役割に応じたバッジのクラスを返す
  def role_badge_class(role)
    case role
    when 'father'
      'border-blue-400 text-blue-600 bg-blue-50'
    when 'mother'
      'border-pink-400 text-pink-600 bg-pink-50'
    else
      'border-base-300 text-base-content bg-base-100'
    end
  end

  # マスキングテープのクラスをランダムに返す
  def random_masking_tape_class
    %w[
      masking-tape--amber
      masking-tape--pink
      masking-tape--mint
      masking-tape--blue
    ].sample
  end

  # マスキングテープの回転角度をランダムに返す
  def random_tape_rotation
    rand(-15..15)
  end
end
