# frozen_string_literal: true

class LineMonthlySummaryMessageBuilder
  class << self
    def build(summary)
      month = summary.fetch(:month)
      group_name = summary.fetch(:group_name)
      total_memories = summary.fetch(:total_memories)
      appear = summary.fetch(:appear)
      post = summary.fetch(:post, { father: 0, mother: 0 })

      header = "#{month.strftime('%Y年%-m月')}の#{group_name}の思い出まとめ✨"
      stats_lines = build_stats_lines(total_memories, appear, post)
      body = body_text(month: month, total_memories: total_memories, appear: appear, post: post)

      [header, '', *stats_lines, '', body].join("\n").strip
    end

    private

    # -----------------------------
    # 集計行
    # -----------------------------
    def build_stats_lines(total_memories, appear, post)
      lines = []
      lines.concat(build_total_line(total_memories))
      lines.concat(build_parent_lines(appear))
      lines.concat(build_parent_post_lines(post))

      children = appear.fetch(:children, [])
      lines.concat(build_children_lines(children)) if children.any?
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

    def build_parent_post_lines(post)
      [
        "・パパの投稿：#{post.fetch(:father, 0)}件",
        "・ママの投稿：#{post.fetch(:mother, 0)}件"
      ]
    end

    def build_children_lines(children)
      active = children
               .sort_by { |c| -c.fetch(:count) }
               .select { |c| c.fetch(:count).positive? }

      return ['・お子さまが写っている思い出：0件'] if active.empty?

      active.map { |c| "・#{c.fetch(:name)}が写っている思い出：#{c.fetch(:count)}件" }
    end

    # -----------------------------
    # 本文（状態判定 → 文面選択）
    # -----------------------------
    def body_text(month:, total_memories:, appear:, post:)
      key = state(total_memories: total_memories, appear: appear, post: post)
      LineMonthlySummaryMessages.messages.fetch(key).sample.call(month)
    end

    # ✅ Rubocop対策：state を10行以内にする（代入を別メソッドへ）
    def state(total_memories:, appear:, post:)
      counts = extract_counts(appear, post)
      too_little_key(total_memories, counts) ||
        appear_zero_key(counts) ||
        post_zero_key(counts) ||
        appear_less_key(counts) ||
        post_less_key(counts) ||
        quiet_month_key(total_memories) ||
        :balanced
    end

    def extract_counts(appear, post)
      {
        father_appear: appear.fetch(:father),
        mother_appear: appear.fetch(:mother),
        father_post: post.fetch(:father, 0),
        mother_post: post.fetch(:mother, 0)
      }
    end

    def too_little_key(total_memories, counts)
      total_post = counts.fetch(:father_post) + counts.fetch(:mother_post)
      total_appear = counts.fetch(:father_appear) + counts.fetch(:mother_appear)
      return :too_little_data if total_memories.zero? || (total_post.zero? && total_appear.zero?)

      nil
    end

    def appear_zero_key(counts)
      father_appear = counts.fetch(:father_appear)
      mother_appear = counts.fetch(:mother_appear)
      return :mother_appear_zero if mother_appear.zero? && father_appear.positive?
      return :father_appear_zero if father_appear.zero? && mother_appear.positive?

      nil
    end

    def post_zero_key(counts)
      father_post = counts.fetch(:father_post)
      mother_post = counts.fetch(:mother_post)
      return :father_post_zero if father_post.zero? && mother_post.positive?
      return :mother_post_zero if mother_post.zero? && father_post.positive?

      nil
    end

    def appear_less_key(counts)
      father_appear = counts.fetch(:father_appear)
      mother_appear = counts.fetch(:mother_appear)
      return :mother_appear_less if mother_appear * 2 < father_appear
      return :father_appear_less if father_appear * 2 < mother_appear

      nil
    end

    def post_less_key(counts)
      father_post = counts.fetch(:father_post)
      mother_post = counts.fetch(:mother_post)
      return :father_post_less if father_post * 2 < mother_post
      return :mother_post_less if mother_post * 2 < father_post

      nil
    end

    def quiet_month_key(total_memories)
      return :quiet_month if total_memories <= 2

      nil
    end
  end
end
