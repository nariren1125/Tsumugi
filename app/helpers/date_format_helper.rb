module DateFormatHelper
  DATE_MD_FORMAT = '%-m/%-d'

  def format_post_date(date)
    return nil if date.blank?

    date.to_date.strftime(DATE_MD_FORMAT)
  end

  def calculate_age(photo_date, birth_date)
    return nil if photo_date.blank? || birth_date.blank?

    ((photo_date - birth_date).to_i / 365.25).floor
  end
end
