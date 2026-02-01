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

  # 役割に応じたテキストのクラスを返す
  def role_text_class(role)
    case role.to_s
    when 'father'
      'text-info/80'
    when 'mother'
      'text-secondary/80'
    else
      'text-base-content/70'
    end
  end

  # 役割に応じたチップのクラスを返す
  def role_member_chip_class(role)
    case role&.to_s
    when 'father'
      'bg-blue-100 text-blue-700'
    when 'mother'
      'bg-pink-100 text-pink-700'
    else
      'bg-base-200 text-base-content'
    end
  end
end
