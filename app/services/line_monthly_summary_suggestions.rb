# frozen_string_literal: true

class LineMonthlySummarySuggestions
  ONE_POST_SUGGESTIONS = {
    father_post: [
      <<~TEXT.strip,
        もしよければ今月、パパも「1件だけ」思い出を残してみるのはどうでしょう？
        写真1枚＋ひとことでも、あとから見返したときの温度がぐっと変わります😊
      TEXT
      <<~TEXT.strip,
        もし余裕のある日に、パパの投稿が「1件だけ」加わると、
        その月の景色が、もう少し立体的に残りそうです📷
      TEXT
      <<~TEXT.strip
        写真1枚だけでも大丈夫です。
        パパの視点がひとつ増えると、アルバムの表情が少し変わりそうです😊
      TEXT
    ],
    mother_post: [
      <<~TEXT.strip,
        もしよければ今月、ママも「1件だけ」思い出を残してみるのはどうでしょう？
        写真1枚＋ひとことでも、あとから見返したときの空気がやさしく残ります😊
      TEXT
      <<~TEXT.strip,
        もし余裕のある日に、ママの投稿が「1件だけ」加わると、
        ふたりで作っているアルバムの感じが、もっと自然に育っていきそうです📷
      TEXT
      <<~TEXT.strip
        写真1枚だけでも大丈夫です。
        ママの視点がひとつ加わると、見返す時間がもう少しあたたかくなりそうです😊
      TEXT
    ]
  }.freeze

  def self.one_post_suggestion_for(target)
    ONE_POST_SUGGESTIONS.fetch(target).sample
  end
end
