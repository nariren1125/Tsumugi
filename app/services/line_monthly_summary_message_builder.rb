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

    # body_text / low_total_text / balanced_text / mother_less_text / father_less_text は現状のままでOK
  end
end
