module PostsHelper
    # tag … PersonTag
    # photo_date … post.photo_date（日付）
    # family_group … post.album.family_group など
    def person_tag_label(tag, photo_date, family_group)
      name = tag.name
  
      # 家族グループ or 撮影日がなければそのまま名前だけ
      return name unless family_group && photo_date
  
      # ★ 子どもモデルの名前・生年月日から探す
      #   ↓ children / birth_date の部分は、実際のモデル名・カラム名に合わせてください
      child = family_group.children.find { |c| c.name == name }
  
      return name unless child&.birth_date # birth_date / birthday など
  
      age_str = age_at(child.birth_date, photo_date)
      age_str ? "#{name}（#{age_str}）" : name
    end
  
    # 生年月日 birth_date と基準日 date から「1才4ヶ月」などの文字列を返す
    def age_at(birth_date, date)
      return nil unless birth_date && date
  
      # 月単位で年齢を計算
      months = (date.year - birth_date.year) * 12 + (date.month - birth_date.month)
      months -= 1 if date.day < birth_date.day # 誕生日まだ来てなければ1ヶ月引く
  
      years = months / 12
      remain_months = months % 12
  
      if years.positive? && remain_months.positive?
        "#{years}才#{remain_months}ヶ月"
      elsif years.positive?
        "#{years}才"
      else
        "#{remain_months}ヶ月"
      end
    end
  end
