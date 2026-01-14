module PostsHelper
  # tag … PersonTag
  # photo_date … post.photo_date（日付）
  # family_group … post.album.family_group など
  def person_tag_label(tag, photo_date, family_group)
    name = tag.name

    # 家族グループ or 撮影日がなければそのまま名前だけ
    return name unless family_group && photo_date

    # 子どもモデルの名前・生年月日から探す
    child = family_group.children.find { |c| c.name == name }
    return name unless child&.birth_date

    age_str = age_at(child.birth_date, photo_date)
    age_str ? "#{name}（#{age_str}）" : name
  end

  # 生年月日 birth_date と基準日 date から「1才4ヶ月」などの文字列を返す
  def age_at(birth_date, date)
    return nil unless birth_date && date

    months = age_in_months(birth_date, date)
    return '0ヶ月' if months.zero?

    years, remain_months = months.divmod(12)
    build_age_label(years, remain_months)
  end

  private

  # 月単位の年齢（誕生日がまだ来ていなければ 1 ヶ月引く）
  def age_in_months(birth_date, date)
    months = ((date.year - birth_date.year) * 12) + (date.month - birth_date.month)
    date.day < birth_date.day ? months - 1 : months
  end

  # 「1才4ヶ月」「2才」「8ヶ月」などの文字列を組み立てる
  def build_age_label(years, months)
    return "#{years}才#{months}ヶ月" if years.positive? && months.positive?
    return "#{years}才" if years.positive?

    "#{months}ヶ月"
  end
end
