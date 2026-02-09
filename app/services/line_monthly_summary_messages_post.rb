# frozen_string_literal: true

class LineMonthlySummaryMessagesPost
  MESSAGES = {
    father_post_zero: [
      lambda { |month|
        suggestion = LineMonthlySummarySuggestions.one_post_suggestion_for(:father_post)

        <<~TEXT.strip
          #{month.month}月も、家族の時間を残してくれてありがとう🧶
          先月はママの投稿で、思い出がたくさん増えていました📷✨

          #{suggestion}

          撮る人も、写る人も。
          ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
        TEXT
      }
    ],
    mother_post_zero: [
      lambda { |month|
        suggestion = LineMonthlySummarySuggestions.one_post_suggestion_for(:mother_post)

        <<~TEXT.strip
          #{month.month}月も、家族の時間を残してくれてありがとう🧶
          先月はパパの投稿で、思い出がたくさん増えていました📷✨

          #{suggestion}

          撮る人も、写る人も。
          ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
        TEXT
      }
    ],
    father_post_less: [
      lambda { |month|
        suggestion = LineMonthlySummarySuggestions.one_post_suggestion_for(:father_post)

        <<~TEXT.strip
          #{month.month}月も、家族の時間を残してくれてありがとう🧶
          先月はママの投稿で思い出がたくさん増えていました📷✨

          #{suggestion}

          撮る人も、写る人も。
          ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
        TEXT
      }
    ],
    mother_post_less: [
      lambda { |month|
        suggestion = LineMonthlySummarySuggestions.one_post_suggestion_for(:mother_post)

        <<~TEXT.strip
          #{month.month}月も、家族の時間を残してくれてありがとう🧶
          先月はパパの投稿で思い出がたくさん増えていました📷✨

          #{suggestion}

          撮る人も、写る人も。
          ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
        TEXT
      }
    ]
  }.freeze

  def self.messages
    MESSAGES
  end
end
