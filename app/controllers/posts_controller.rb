class PostsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  before_action :set_person_context, only: %i[new edit]

  def new
    @post =
      if params[:draft_post_id].present?
        current_user.posts.find(params[:draft_post_id])
      else
        Post.new
      end
  end

  def edit; end

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

  def update
    if @post.update(post_params)
      redirect_to albums_path, notice: t('flash.posts.updated')
    else
      set_person_context
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to albums_path, notice: t('flash.posts.deleted')
  end

  def select_photos; end

  #  写真を仮保存し、確認プレビューを表示する
  def confirm_photos
    images = params.dig(:post, :images)
    return redirect_to_no_photos if images.blank?

    max = 5

    # サーバー側で必ず制限する（最重要）
    limited_images = images.first(max)

    # 画面表示用（何枚切り捨てたか）
    @dropped_files_count = [images.size - max, 0].max

    @post = build_draft_post
    attach_photos(@post, limited_images)
  end

  private

  # ==================================================
  # Strong Parameters
  # ==================================================
  def post_params
    params.require(:post).permit(
      :title,
      :content,
      :child_id,
      :photo_date,
      person_tag_ids: []
    )
  end

  # ==================================================
  # Confirm Photos Flow
  # ==================================================

  def redirect_to_no_photos
    redirect_to select_photos_posts_path,
                alert: t('flash.posts.no_photos_selected')
  end

  def build_draft_post
    post = current_user.posts.build(album: temp_album)
    post.save(validate: false)
    post
  end

  def attach_photos(post, images)
    images.each_with_index do |img, index|
      post.photos.create!(
        image: img,
        position: index
      )
    end
  end

  # ==================================================
  # Album
  # ==================================================

  def temp_album
    family = current_family_group
    raise ActiveRecord::RecordNotFound, 'family_group not selected' unless family

    family.albums.first || family.albums.create!(title: '思い出アルバム')
  end

  # ==================================================
  # Before Actions
  # ==================================================

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def authorize_user!
    return if @post.user == current_user

    redirect_to albums_path, alert: t('flash.authorization.failed')
  end

  # 人物タグの共通セット処理
  def set_person_context
    family_group = current_family_group
    @has_family_group = family_group.present?
    @person_tags =
      if family_group
        PersonTag.where(family_group_id: family_group.id).order(:name)
      else
        []
      end
  end

  # LINE通知を家族グループのメンバーに送信
  def notify_family_group_members(post)
    family_group = post.album.family_group
    return unless family_group
  
    notifier = LineNotifier.new
    family_group.users.each do |member|
      next if member.id == current_user.id
      next if member.line_uid.blank?
  
      notifier.push_message(
        member.line_uid,
        "#{current_user.name}さんが新しい思い出を投稿しました📸\n\n#{post.title.presence || 'タイトルなし'}"
      )
    end
  end
end
