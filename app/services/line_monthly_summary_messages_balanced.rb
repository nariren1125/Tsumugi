# frozen_string_literal: true

class LineMonthlySummaryMessagesBalanced
  MESSAGES = {
    balanced: [
      lambda { |month|
        <<~TEXT.strip
          #{month.month}月も、家族の時間を残してくれてありがとう🧶
          撮る人も、写る人も。
          自然に入れ替わりながら思い出が増えていて、とても素敵でした📷✨

          このまま、ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
        TEXT
      },
      lambda { |month|
        <<~TEXT.strip
          #{month.month}月もありがとう🧶
          先月は、ふたりの関わり方がとても自然で、
          日常の空気感がそのまま残っていました📷✨

          特別なことをしなくても、こうして残る時間が宝物になります😊
          これからも、今のペースで思い出を紡いでいきましょう🐿️
        TEXT
      }
    ]
  }.freeze

  def self.messages
    MESSAGES
  end
end
