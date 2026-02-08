# frozen_string_literal: true

class LineMonthlySummaryMessagesBase
  MESSAGES = {
    too_little_data: [
      lambda { |month|
        <<~TEXT.strip
          #{month.month}月も、家族の時間を残してくれてありがとう🧶
          今月は記録が少なめでしたが、そんな月があっても大丈夫です😊

          もし余裕のあるときに、写真1枚＋ひとことだけでも残せたら、
          あとから見返すときの“その月の空気”が、そっと戻ってきます📷

          撮る人も、写る人も。
          できるときに、できるかたちで。思い出を紡いでいきましょう🐿️
        TEXT
      }
    ],
    quiet_month: [
      lambda { |month|
        <<~TEXT.strip
          #{month.month}月も、家族の時間を残してくれてありがとう🧶
          今月は思い出が少なめでしたが、そんな月があっても大丈夫です😊

          もし余裕のある日に、写真1枚だけでも残せたら、
          あとから見返すときの“その月の空気”が、そっと戻ってきます📷

          撮る人も、写る人も。
          無理のないペースで、思い出を紡いでいきましょう🐿️
        TEXT
      }
    ]
  }.freeze

  def self.messages
    MESSAGES
  end
end
