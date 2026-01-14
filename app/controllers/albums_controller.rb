class AlbumsController < ApplicationController
  before_action :require_login

  def index
    family = current_family_group

    @posts_by_year =
      if family
        build_grouped_posts(family)
      else
        {}
      end
  end

  private

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
    ).call.includes(:photos).order(photo_date: :desc, created_at: :desc, id: :desc)
  end

  # 撮影日あり・なしで分割
  def split_posts(posts)
    with_date    = posts.select { |p| p.photo_date.present? }
    without_date = posts.reject { |p| p.photo_date.present? }
    [with_date, without_date]
  end

  # 年別にグループ化して降順ソート
  def group_by_year(posts)
    posts.group_by { |p| p.photo_date.year }
         .sort_by { |year, _| -year }
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
    params[:year].present? || (params[:child_id].present? && params[:age_years].present?)
  end

  # Strong Parameters
  def search_params
    params.permit(:year, :child_id, :age_years, person_tag_ids: [])
  end
end
