
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
      posts = base_scope

      # 1) 年齢モード（child_id + age_years 必須）
      # 家族アルバム（複数の子どもが写る）前提なので、
      # 年齢は「子どもの人物タグが付いている投稿」×「撮影日レンジ」で絞り込みます。
      if age_mode?
        posts = apply_age_filter(posts)
        posts = apply_person_tags_and(posts) # 年齢モードでも人物タグ（AND）併用OK
        return posts
      end

      # 2) 通常モード（year + person_tags AND）
      posts = apply_year_filter(posts)
      posts = apply_person_tags_and(posts)
      posts
    end

    private

    # AlbumsController から scope を渡している場合に二重適用しない
    # - scope が Post.all のとき：family_group 絞り込みが必要
    # - それ以外（joins(:album).where... 等）のとき：そのまま使う
    def base_scope
      scope == Post.all ? scope.for_family_group(family_group) : scope
    end

    def age_mode?
      params[:child_id].present? && params[:age_years].present?
    end

    # ===== 年（年度）で絞り込み =====
    def apply_year_filter(posts)
      return posts if params[:year].blank?

      year = params[:year].to_i
      from = Date.new(year, 1, 1)
      to   = Date.new(year, 12, 31)

      posts.where(photo_date: from..to)
    end

    # ===== 人物タグを AND で絞り込み =====
    # ids が [1,2] のとき「1と2の両方が付いている投稿」だけを返す
    def apply_person_tags_and(posts)
      ids = Array(params[:person_tag_ids]).compact_blank.map(&:to_i).uniq
      return posts if ids.empty?

      posts
        .joins(:person_tags)
        .where(person_tags: { id: ids, family_group_id: family_group.id })
        .group('posts.id')
        .having('COUNT(DISTINCT person_tags.id) = ?', ids.size)
    end

    # ===== 子ども年齢で絞り込み =====
    # 「子ども（child_id）」は Children テーブルの子ども
    # 「年齢（age_years）」は 0=0歳以上1歳未満, 6=6歳以上7歳未満 のレンジ
    #
    # 家族アルバム前提：投稿が特定の子1人に紐づくとは限らないため、
    # Post.child_id ではなく「その子の人物タグ(person_tag)」が付いている投稿を対象にする。
    def apply_age_filter(posts)
      child = family_group.children.find_by(id: params[:child_id])
      return posts.none if child.nil? || child.birth_date.blank?

      age  = params[:age_years].to_i
      from = child.birth_date.advance(years: age)
      to   = child.birth_date.advance(years: age + 1)

      # Child 作成時に ensure_person_tag している前提で、同名の人物タグを取得
      tag = family_group.person_tags.find_by(name: child.name)
      return posts.none if tag.nil?

      # 1) 撮影日レンジ（photo_date 必須）
      # 2) その子の人物タグが付いている投稿
      #
      # joins(:post_person_tags) を使うことで SQL が単純になりやすく、
      # person_tags AND の joins(:person_tags) と衝突しづらい
      posts
        .where(photo_date: from...to)
        .joins(:post_person_tags)
        .where(post_person_tags: { person_tag_id: tag.id })
    end
  end
end
