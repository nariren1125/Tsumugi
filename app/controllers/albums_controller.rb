# app/controllers/albums_controller.rb
class AlbumsController < ApplicationController
  before_action :require_login

  def index
    family = current_family_group

    @person_tags = family ? family.person_tags.order(:name) : []
    @children    = family ? family.children.order(:created_at) : []

    # ===== 動的候補（年度・年齢） =====
    if family
      set_dynamic_filter_options(family)
      @posts_by_year = build_grouped_posts(family)
    else
      @available_years = []
      @ages_by_child_id = {}
      @posts_by_year = {}
    end
  end

  private

  # ===== 動的フィルタ候補を実データから作る =====
  #
  # @available_years:
  #   写真日(photo_date)が入っている投稿から「存在する年」だけを抽出
  #
  # @ages_by_child_id:
  #   子どもごとに「その子のタグが付いた投稿」の photo_date から
  #   birth_date 基準で満年齢を計算し、存在する年齢のみを候補化
  def set_dynamic_filter_options(family)
    base_posts = Post.for_family_group(family).where.not(photo_date: nil)

    @available_years = extract_available_years(base_posts)
    @ages_by_child_id = build_ages_by_child_id(family, base_posts)
  end

  def extract_available_years(posts)
    posts
      .distinct
      .pluck(Arel.sql('EXTRACT(YEAR FROM photo_date)'))
      .map(&:to_i)
      .uniq
      .sort
      .reverse
  end

  def build_ages_by_child_id(family, base_posts)
    # 子ども名と同名の person_tag がある前提（Child#ensure_person_tag）
    tags_by_name =
      family
        .person_tags
        .where(name: @children.map(&:name))
        .index_by(&:name)

    @children.each_with_object({}) do |child, hash|
      next if child.birth_date.blank?

      tag = tags_by_name[child.name]
      next if tag.nil?

      dates =
        base_posts
          .joins(:post_person_tags)
          .where(post_person_tags: { person_tag_id: tag.id })
          .distinct
          .pluck(:photo_date)

      ages =
        dates
          .map { |d| age_years_on(child.birth_date, d) }
          .uniq
          .sort

      hash[child.id] = ages
    end
  end

  # 撮影日(photo_date)時点での満年齢を返す
  def age_years_on(birth_date, photo_date)
    years = photo_date.year - birth_date.year
    years -= 1 if before_birthday?(birth_date, photo_date)
    years
  end

  def before_birthday?(birth_date, photo_date)
    photo_date.month < birth_date.month ||
      (photo_date.month == birth_date.month && photo_date.day < birth_date.day)
  end

  # ===== グルーピング処理の本体 =====
  def build_grouped_posts(family)
    posts = load_posts(family)

    with_date    = posts.where.not(photo_date: nil)
    without_date = posts.where(photo_date: nil)

    grouped = group_by_year(with_date)

    append_without_date(grouped, without_date)
  end

  # 投稿を写真付きでロード（N+1回避）
  def load_posts(family)
    # 家族グループに属する投稿をベースに検索
    base = Post.joins(:album).where(albums: { family_group_id: family.id })

    Posts::Search.new(
      scope: base,
      family_group: family,
      params: search_params
    ).call
      .includes(:photos)
      .order(photo_date: :desc, created_at: :desc, id: :desc)
  end

  # 年別にグループ化して降順ソート
  def group_by_year(posts)
    posts
      .group_by { |p| p.photo_date.year }
      .sort_by { |year, _posts| -year }
      .to_h
  end

  # 撮影日未設定グループを最後尾に追加
  def append_without_date(grouped, without_date)
    return grouped if hide_without_date_group?

    grouped['撮影日未設定'] = without_date if without_date.any?
    grouped
  end

  # 撮影日未設定グループを非表示にする条件
  def hide_without_date_group?
    params[:year].present? ||
      (params[:child_id].present? && params[:age_years].present?)
  end

  # Strong Parameters
  def search_params
    params.permit(:year, :child_id, :age_years, person_tag_ids: [])
  end
end
