# app/controllers/albums_controller.rb
class AlbumsController < ApplicationController
  before_action :require_login

  def index
    @family_groups = current_user.family_groups.order(:created_at)

    family = current_family_group
    @person_tags, @children = load_tags_and_children(family)

    if family
      assign_dynamic_filter_options(family)
      @posts_by_year = build_grouped_posts(family)
    else
      assign_empty_filter_options
    end
  end

  def switch
    family_group = current_user.family_groups.find(params[:family_group_id])
    session[:current_family_group_id] = family_group.id

    flash[:notice] = "#{family_group.name}のアルバムに切り替えました"
    redirect_back(fallback_location: albums_path)
  end

  private

  # ===== 家族ごとのタグ・子ども一覧を読み込む =====
  def load_tags_and_children(family)
    if family
      [
        family.person_tags.order(:name),
        family.children.order(:created_at)
      ]
    else
      [[], []]
    end
  end

  # ===== family が無いときのフィルタ初期化 =====
  def assign_empty_filter_options
    @available_years = []
    @ages_by_child_id = {}
    @posts_by_year = {}
  end

  # ===== 動的フィルタ候補を実データから作る =====
  #
  # @available_years:
  #   写真日(photo_date)が入っている投稿から「存在する年」だけを抽出
  #
  # @ages_by_child_id:
  #   子どもごとに「その子のタグが付いた投稿」の photo_date から
  #   birth_date 基準で満年齢を計算し、存在する年齢のみを候補化
  def assign_dynamic_filter_options(family)
    base_posts = Post.for_family_group(family).published.where.not(photo_date: nil)

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
    tags_by_name = child_tags_by_name(family)

    @children.each_with_object({}) do |child, hash|
      ages = build_ages_for_child(child, tags_by_name[child.name], base_posts)
      hash[child.id] = ages if ages.present?
    end
  end

  # 子ども名と同名の person_tag 一覧を name => tag で引けるようにする
  # （Child#ensure_person_tag で作成されている前提）
  def child_tags_by_name(family)
    family
      .person_tags
      .where(name: @children.map(&:name))
      .index_by(&:name)
  end

  # 特定の子どもの「存在する年齢候補」を算出
  def build_ages_for_child(child, tag, base_posts)
    return [] if child.birth_date.blank? || tag.nil?

    dates = dates_for_child_tag(base_posts, tag.id)
    ages_from_dates(child, dates)
  end

  # その子のタグが付いた投稿の撮影日一覧
  def dates_for_child_tag(base_posts, tag_id)
    base_posts
      .joins(:post_person_tags)
      .where(post_person_tags: { person_tag_id: tag_id })
      .distinct
      .pluck(:photo_date)
  end

  # 撮影日一覧から満年齢一覧を作る
  def ages_from_dates(child, dates)
    dates
      .map { |date| age_years_on(child.birth_date, date) }
      .uniq
      .sort
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

    drafts    = posts.draft
    published = posts.published

    with_date    = published.where.not(photo_date: nil)
    without_date = published.where(photo_date: nil)

    grouped = group_by_year(with_date)

    # ✅ 念のため：公開済みで撮影日未設定が残っていれば最後に出す
    append_without_date(grouped, without_date)

    # ✅ 最後尾に「下書き保存した思い出」を追加
    append_drafts(grouped, drafts)
  end

  # 下書きグループを最後尾に追加
  def append_drafts(grouped, drafts)
    return grouped if drafts.blank?
    return grouped if hide_draft_group?

    grouped.merge('下書き保存した思い出' => drafts)
  end

  # 下書きグループを非表示にする条件（必要最低限で安牌）
  def hide_draft_group?
    params[:year].present?
  end

  # 投稿を写真付きでロード（N+1回避）
  def load_posts(family)
    # 家族グループに属する投稿をベースに検索
    base = Post.joins(:album).where(albums: { family_group_id: family.id })

    Posts::Search
      .new(
        scope: base,
        family_group: family,
        params: search_params
      )
      .call
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
