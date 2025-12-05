class AlbumsController < ApplicationController
  before_action :require_login

  def index
    family = current_user.family_group

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

    with_date, without_date = split_posts(posts)

    grouped = group_by_year(with_date)

    append_without_date(grouped, without_date)
  end

  # 投稿を写真付きでロード（N+1回避）
  def load_posts(family)
    family.posts.includes(:photos)
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
    grouped['撮影日未設定'] = without_date if without_date.any?
    grouped
  end

  # ログイン必須
  def require_login
    redirect_to root_path, alert: t('flash.login.required') if session[:user_id].blank?
  end
end
