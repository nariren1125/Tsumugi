# app/queries/posts/search.rb
module Posts
  class Search
    attr_reader :scope, :params, :family_group

    def initialize(family_group:, params:, scope: Post.all)
      @scope = scope
      @family_group = family_group
      @params = params
    end

    def call
      posts = scope.for_family_group(family_group)

      # 1) 年齢モード（child_id + age_years 必須）
      if age_mode?
        posts = apply_age_filter(posts)
        posts = apply_person_tags_and(posts) # 年齢モードでも人物タグ併用OK
        return posts
      end

      # 2) 通常モード（year + person_tags AND）
      posts = apply_year_filter(posts)
      apply_person_tags_and(posts)
    end

    private

    def age_mode?
      params[:child_id].present? && params[:age_years].present?
    end

    def apply_year_filter(posts)
      return posts if params[:year].blank?

      year = params[:year].to_i
      from = Date.new(year, 1, 1)
      to   = Date.new(year, 12, 31)

      posts.where(photo_date: from..to)
    end

    def apply_person_tags_and(posts)
      ids = Array(params[:person_tag_ids]).compact_blank.map(&:to_i).uniq
      return posts if ids.empty?

      posts
        .joins(:person_tags)
        .where(person_tags: { id: ids, family_group_id: family_group.id })
        .group('posts.id')
        .having('COUNT(DISTINCT person_tags.id) = ?', ids.size)
    end

    def apply_age_filter(posts)
      child = family_group.children.find(params[:child_id])
      age_years = params[:age_years].to_i

      start_date = child.birth_date.advance(years: age_years)
      end_date   = child.birth_date.advance(years: age_years + 1)

      posts
        .where(child_id: child.id)
        .where(photo_date: start_date...end_date)
    end
  end
end
