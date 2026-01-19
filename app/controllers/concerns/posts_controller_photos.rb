# frozen_string_literal: true

# 投稿の写真（signed_id/session/attach）や create・draft の共通処理をまとめる
# - Controller本体の行数を減らす目的
# - ルーティング/アクションの挙動は変えない
module PostsControllerPhotos
  extend ActiveSupport::Concern

  private

  # =========================
  # Strong Parameters
  # =========================
  def post_params
    params.require(:post).permit(:title, :content, :child_id, :photo_date, person_tag_ids: [])
  end

  # =========================
  # signed_id の取得
  # =========================
  def selected_image_signed_ids
    Array(params.dig(:post, :images)).compact_blank
  end

  def pending_signed_ids
    Array(session[self.class::SESSION_KEY]).compact_blank
  end

  def pending_blobs(signed_ids)
    signed_ids.map { |sid| ActiveStorage::Blob.find_signed!(sid) }
  end

  # =========================
  # session 操作
  # =========================
  def clear_pending_photos_session
    session.delete(self.class::SESSION_KEY)
  end

  def redirect_to_no_photos
    clear_pending_photos_session
    redirect_to select_photos_posts_path, alert: t('flash.posts.no_photos_selected')
  end

  # =========================
  # create（本投稿）用：分割
  # =========================
  def build_post_for_create
    @post = current_user.posts.build(post_params.merge(album: temp_album))
  end

  def save_post_and_photos?(signed_ids)
    return false unless @post.save

    attach_photos(@post, signed_ids)
    true
  end

  def handle_create_success
    clear_pending_photos_session
    redirect_to albums_path, notice: t('flash.posts.created')
  end

  def handle_create_failure(signed_ids)
    prepare_new_view_for_retry(signed_ids)
    render :new, status: :unprocessable_entity
  end

  def prepare_new_view_for_retry(signed_ids)
    @pending_blobs = pending_blobs(signed_ids)
  end

  def handle_create_invalid_signature
    clear_pending_photos_session
    redirect_to_no_photos
  end

  # =========================
  # draft（下書き）用：分割
  # =========================
  def build_post_for_draft
    @post = current_user.posts.new(post_params.merge(album: temp_album))
    @post.status = :draft
  end

  def save_draft_and_photos?(signed_ids)
    return false unless @post.save

    attach_photos(@post, signed_ids)
    true
  end

  def handle_draft_success
    clear_pending_photos_session
    redirect_to albums_path, notice: t('flash.posts.draft_saved')
    # 失敗時
    flash.now[:alert] = t('flash.posts.draft_failed')
  end

  def handle_draft_failure(signed_ids)
    @pending_blobs = pending_blobs(signed_ids)
    flash.now[:alert] = t('flash.posts.draft_save_failed')
    render :new, status: :unprocessable_entity
  end

  # =========================
  # Photo 作成（blob attach）
  # =========================
  def attach_photos(post, signed_ids)
    signed_ids.each_with_index do |signed_id, index|
      blob = ActiveStorage::Blob.find_signed!(signed_id)
      post.photos.create!(image: blob, position: index)
    end
  end

  # =========================
  # 投稿先アルバム（暫定）
  # =========================
  def temp_album
    family = current_family_group
    raise ActiveRecord::RecordNotFound, 'family_group not selected' unless family

    family.albums.first || family.albums.create!(title: '思い出アルバム')
  end

  # =========================
  # 既存投稿向け（必要最低限）
  # =========================
  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def authorize_user!
    return if @post.user == current_user

    redirect_to albums_path, alert: t('flash.authorization.failed')
  end

  # =========================
  # フォーム表示用（人物タグ）
  # =========================
  def set_person_context
    family_group = current_family_group
    @has_family_group = family_group.present?
    @person_tags = family_group ? PersonTag.where(family_group_id: family_group.id).order(:name) : []
  end
end
