# ================================
# コントローラー: 投稿関連
# ================================
class PostsController < ApplicationController
  # 認証と前処理
  before_action :require_login
  before_action :set_post, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]
  before_action :set_person_context, only: %i[new edit]

  # 新規投稿画面
  def new
    @post = if params[:draft_post_id].present?
              current_user.posts.find(params[:draft_post_id])
            else
              Post.new
            end
  end

  # 編集画面
  def edit; end

  # 投稿作成処理
  def create
    Rails.logger.debug { "POST PARAMS: #{post_params}" }

    if @post.update(post_params)
      notify_family_group_members(@post)
      redirect_to albums_path, notice: t('flash.posts.created')
    else
      set_person_context
      render :new, status: :unprocessable_entity
    end
  end

  # 投稿更新処理
  def update
    if @post.update(post_params)
      redirect_to albums_path, notice: t('flash.posts.updated')
    else
      set_person_context
      render :edit, status: :unprocessable_entity
    end
  end

  # 投稿削除処理
  def destroy
    @post.destroy
    redirect_to albums_path, notice: t('flash.posts.deleted')
  end

  # 写真選択画面
  def select_photos; end

  # 写真確認（仮保存）
  def confirm_photos
    images = params.dig(:post, :images)
    return redirect_to_no_photos if images.blank?

    max = 5
    limited_images = images.first(max)
    @dropped_files_count = [images.size - max, 0].max

    @post = build_draft_post
    attach_photos(@post, limited_images)
  end

  private

  # ストロングパラメータ
  def post_params
    params.require(:post).permit(:title, :content, :child_id, :photo_date, person_tag_ids: [])
  end

  # 写真未選択リダイレクト
  def redirect_to_no_photos
    redirect_to select_photos_posts_path, alert: t('flash.posts.no_photos_selected')
  end

  # 仮投稿生成
  def build_draft_post
    post = current_user.posts.build(album: temp_album)
    post.save(validate: false)
    post
  end

  # 写真を添付
  def attach_photos(post, images)
    images.each_with_index do |img, index|
      post.photos.create!(image: img, position: index)
    end
  end

  # 一時アルバム取得
  def temp_album
    family = current_family_group
    raise ActiveRecord::RecordNotFound, 'family_group not selected' unless family

    family.albums.first || family.albums.create!(title: '思い出アルバム')
  end

  # 投稿取得
  def set_post
    @post = current_user.posts.find(params[:id])
  end

  # 投稿権限確認
  def authorize_user!
    return if @post.user == current_user

    redirect_to albums_path, alert: t('flash.authorization.failed')
  end

  # 人物タグのセット
  def set_person_context
    family_group = current_family_group
    @has_family_group = family_group.present?
    @person_tags = family_group ? PersonTag.where(family_group_id: family_group.id).order(:name) : []
  end

  # LINE通知を家族グループのメンバーに送信
  def notify_family_group_members(post)
    Rails.logger.info "=== LINE通知処理 START ==="

    family_group = post.album.family_group
    return unless family_group

    notifier = LineNotifier.new
    recipient_uids = line_uids_to_notify(family_group.users)
    message = build_post_message(post)

    Rails.logger.info "送信対象UID: #{recipient_uids.inspect}"

    recipient_uids.each do |uid|
      Rails.logger.info "LINE送信: #{uid}"
      notifier.push_message(uid, message)
    end

    Rails.logger.info "=== LINE通知処理 END ==="
  end

  # 通知対象のLINE UIDリストを抽出（自分以外でUIDが存在するユーザー）
  def line_uids_to_notify(users)
    users.reject { |u| u.id == current_user.id || u.line_uid.blank? }.map(&:line_uid)
  end

  # 投稿に関する通知メッセージを生成
  def build_post_message(post)
    title = post.title.presence || 'タイトルなし'
    "#{current_user.name}さんが新しい思い出を投稿しました📸\n\n#{title}"
  end
end
