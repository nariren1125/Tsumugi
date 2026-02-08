# frozen_string_literal: true

class LineMonthlySummaryMessageBuilder
  class << self
    def build(summary)
      month = summary.fetch(:month)
      total_memories = summary.fetch(:total_memories)
      appear = summary.fetch(:appear)

      header = "#{month.strftime('%Y年%-m月')}の思い出まとめ✨"
      stats_lines = build_stats_lines(total_memories, appear)
      body = body_text(month: month, total_memories: total_memories, appear: appear)

      [header, '', *stats_lines, '', body].join("\n").strip
    end

    private

    def build_stats_lines(total_memories, appear)
      lines = []
      lines.concat(build_total_line(total_memories))
      lines.concat(build_parent_lines(appear))
      lines.concat(build_children_lines(appear.fetch(:children)))
      lines
    end

    def build_total_line(total_memories)
      ["・今月の思い出：#{total_memories}件"]
    end

    def build_parent_lines(appear)
      [
        "・パパが写っている思い出：#{appear.fetch(:father)}件",
        "・ママが写っている思い出：#{appear.fetch(:mother)}件"
      ]
    end

    def build_children_lines(children)
      active_children = children_with_count(children)
      top = active_children.first(3).map { |c| "・#{c.fetch(:name)}：#{c.fetch(:count)}件" }

      other_line = others_line(active_children.size)
      other_line ? top + [other_line] : top
    end

    def children_with_count(children)
      children
        .select { |c| c.fetch(:count).positive? }
        .sort_by { |c| -c.fetch(:count) }
    end

    def others_line(active_size)
      return nil unless active_size > 3

      "・ほか#{active_size - 3}人"
    end

    # -----------------------------
    # 本文（短くしてRubocop通す）
    # -----------------------------
    def body_text(month:, total_memories:, appear:)
      return low_total_text(month) if low_total?(total_memories)

      father_count = appear.fetch(:father)
      mother_count = appear.fetch(:mother)

      return mother_zero_text(month) if mother_count.zero?
      return mother_less_text(month) if mother_much_less?(father_count, mother_count)

      balanced_text(month)
    end

    def low_total?(total_memories)
      total_memories <= 2
    end

    def mother_much_less?(father_count, mother_count)
      mother_count * 2 < father_count
    end

    # --------
    # 文面
    # --------
    def low_total_text(_month)
      <<~TEXT.strip
        今月は思い出が少なめでした🌱
        来月は写真を1枚でも残せると嬉しいですね！
      TEXT
    end

    def mother_zero_text(month)
      <<~TEXT.strip
        #{month.month}月も、家族の時間を残してくれてありがとう🧶
        先月はパパとお子さまの思い出がたくさんあって、とても素敵でした📷

        今月は、ママも一緒に写っている写真が少し増えると、
        あとから見返したときの思い出が、もっと豊かになりそうです😊

        撮る人も、写る人も。
        ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
      TEXT
    end

    def mother_less_text(month)
      <<~TEXT.strip
        #{month.month}月も、家族の時間を残してくれてありがとう🧶
        先月はパパとお子さまの思い出がたくさんあって、とても素敵でした📷✨

        今月は、ママも一緒に写っている写真が少し増えると、
        お互いの“そのときの空気”まで、もっとたくさん残せそうです😊

        撮る人も、写る人も。
        ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
      TEXT
    end

    def balanced_text(month)
      <<~TEXT.strip
        #{month.month}月も、家族の時間を残してくれてありがとう🧶
        撮る人も、写る人も。
        自然に入れ替わりながら思い出が増えていて、とても素敵でした📷✨

        このまま、ふたりで少しずつ、家族の思い出を紡いでいきましょう🐿️
      TEXT
    end
  end
end
