# ================================
# コントローラー: 投稿関連
# ================================
class PostsController < ApplicationController
  MAX_PHOTOS = 5

  # select→prepare_uploads→new→create の間で
  # 「選択した画像の signed_id 配列」を一時保持する session キー
  SESSION_KEY = :pending_post_image_signed_ids

  # 認証と前処理
  before_action :require_login

  # 既存投稿を扱うアクションのみ @post を読み込む
  before_action :set_post, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  # new/create/edit/update は人物タグのフォーム表示に必要
  before_action :set_person_context, only: %i[new create edit update save_draft]

  # ----------------------------
  # GET /posts/new
  # ----------------------------
  # ✅ 新規投稿フォーム（ここではDBを触らない）
  # session に入っている signed_id から Blob を取り出して表示に使う
  def new
    signed_ids = pending_signed_ids
    return redirect_to_no_photos if signed_ids.empty?

    # 入力フォーム用（保存は create）
    @post = Post.new

    # new画面で「選択した写真」を表示するためのBlob配列
    @pending_blobs = pending_blobs(signed_ids)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    # signed_id が不正 or Blob が見つからない場合はセッションを捨てて選択画面へ
    clear_pending_photos_session
    redirect_to_no_photos
  end

  # ----------------------------
  # POST /posts/prepare_uploads
  # ----------------------------
  # ✅ 「次へ」の着地
  # DirectUpload後に得られた signed_id を session に保存して new にリダイレクト
  def prepare_uploads
    signed_ids = selected_image_signed_ids
    return redirect_to_no_photos if signed_ids.empty?

    # 上限枚数までに制限
    limited_ids = signed_ids.first(MAX_PHOTOS)

    # session に保存してフォーム入力へ
    session[SESSION_KEY] = limited_ids
    redirect_to new_post_path
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    clear_pending_photos_session
    redirect_to_no_photos
  end

  # 編集画面（既存の導線を維持）
  def edit; end

  # ----------------------------
  # POST /posts
  # ----------------------------
  # ✅ DB保存は「投稿する」を押した時だけ
  # - Post を作る
  # - 保存に成功したら Photo を作って blob を attach
  # - 最後に session を必ずクリア
  def create
    signed_ids = pending_signed_ids
    return redirect_to_no_photos if signed_ids.empty?

    build_post_for_create

    if save_post_and_photos?(signed_ids)
      notify_family_group_members_safely(@post) # ✅ ここで通知
      return handle_create_success
    end

    handle_create_failure(signed_ids)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    handle_create_invalid_signature
  end

  # ---- 旧導線（残してOK / 今回は使わない想定） ----
  def select_photos; end

  # 既存投稿の更新
  def update
    if @post.update(post_params)
      redirect_to albums_path, notice: t('flash.posts.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 既存投稿の削除
  def destroy
    @post.destroy
    redirect_to albums_path, notice: t('flash.posts.deleted')
  end

  # 下書き保存（写真含む）
  def save_draft
    signed_ids = pending_signed_ids
    return redirect_to_no_photos if signed_ids.empty?

    @post = current_user.posts.new(post_params.merge(album: temp_album))
    @post.status = :draft

    if @post.save
      attach_photos(@post, signed_ids)
      clear_pending_photos_session
      redirect_to albums_path, notice: '下書きを保存しました'
    else
      @pending_blobs = pending_blobs(signed_ids)
      flash.now[:alert] = '下書きの保存に失敗しました'
      render :new, status: :unprocessable_entity
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    handle_create_invalid_signature
  end

  private

  # ----------------------------
  # Strong Parameters
  # ----------------------------
  def post_params
    params.require(:post).permit(:title, :content, :child_id, :photo_date, person_tag_ids: [])
  end

  # ----------------------------
  # signed_id の取得
  # ----------------------------

  # select_photos から送られてくる signed_id 配列（DirectUpload後に埋まる）
  def selected_image_signed_ids
    Array(params.dig(:post, :images)).compact_blank
  end

  # session に保持している signed_id 配列
  def pending_signed_ids
    Array(session[SESSION_KEY]).compact_blank
  end

  # signed_id から Blob を取得（new画面のサムネ表示用）
  def pending_blobs(signed_ids)
    signed_ids.map { |sid| ActiveStorage::Blob.find_signed!(sid) }
  end

  # ----------------------------
  # session 操作
  # ----------------------------
  def clear_pending_photos_session
    session.delete(SESSION_KEY)
  end

  # 写真未選択時の戻り先（sessionもクリアして迷子防止）
  def redirect_to_no_photos
    clear_pending_photos_session
    redirect_to select_photos_posts_path, alert: t('flash.posts.no_photos_selected')
  end

  # ----------------------------
  # RuboCop対策：createの分割
  # ----------------------------

  # Post の生成を分離（create の複雑さを下げる）
  def build_post_for_create
    # Album は「投稿する」時点で初めて確定させる
    @post = current_user.posts.build(post_params.merge(album: temp_album))
  end

  # Post 保存 → 成功したら Photo 作成（attach）まで実行（true/false を返すので ?）
  def save_post_and_photos?(signed_ids)
    return false unless @post.save

    attach_photos(@post, signed_ids)
    true
  end

  # 成功時の共通処理（createを短くする）
  def handle_create_success
    clear_pending_photos_session
    redirect_to albums_path, notice: t('flash.posts.created')
  end

  # 失敗時の共通処理（createを短くする）
  def handle_create_failure(signed_ids)
    prepare_new_view_for_retry(signed_ids)
    render :new, status: :unprocessable_entity
  end

  # create 失敗時に new を再描画できるよう準備
  def prepare_new_view_for_retry(signed_ids)
    @pending_blobs = pending_blobs(signed_ids)
    # set_person_context は before_action で入っている想定
  end

  # 署名不正時の共通処理（createを短くする）
  def handle_create_invalid_signature
    clear_pending_photos_session
    redirect_to_no_photos
  end

  # ----------------------------
  # Photo 作成（blob attach）
  # ----------------------------
  def attach_photos(post, signed_ids)
    signed_ids.each_with_index do |signed_id, index|
      blob = ActiveStorage::Blob.find_signed!(signed_id)

      # Photoモデルが image(attached) を持つ前提
      post.photos.create!(image: blob, position: index)
    end
  end

  # ----------------------------
  # 投稿先アルバム（暫定）
  # ----------------------------
  def temp_album
    family = current_family_group
    raise ActiveRecord::RecordNotFound, 'family_group not selected' unless family

    # 初回のみ「思い出アルバム」を作成して使い回す
    family.albums.first || family.albums.create!(title: '思い出アルバム')
  end

  # ----------------------------
  # 既存投稿向け
  # ----------------------------
  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def authorize_user!
    return if @post.user == current_user

    redirect_to albums_path, alert: t('flash.authorization.failed')
  end

  # ----------------------------
  # フォーム表示用（人物タグ）
  # ----------------------------
  def set_person_context
    family_group = current_family_group
    @has_family_group = family_group.present?
    @person_tags = family_group ? PersonTag.where(family_group_id: family_group.id).order(:name) : []
  end

  # ----------------------------
  # LINE通知（既存）
  # ----------------------------
  def notify_family_group_members(post)
    notifier = line_notifier
    recipient_uids_for(post).each { |uid| notifier.push_flex_message(uid, post) }
  end

  def recipient_uids_for(post)
    family_group = post.album.family_group
    return [] unless family_group

    family_group.users.reject { |u| u.id == current_user.id || u.line_uid.blank? }.map(&:line_uid)
  end

  def line_notifier
    @line_notifier ||= LineNotifier.new
  end

  # create時の通知は「失敗しても投稿は成功扱い」にしたいので安全に実行する
  def notify_family_group_members_safely(post)
    notify_family_group_members(post)
  rescue StandardError => e
    Rails.logger.warn("[LINE notify failed] post_id=#{post.id} error=#{e.class} message=#{e.message}")
  end

  def attach_pending_photos!(post, signed_ids)
    signed_ids.each do |signed_id|
      blob = ActiveStorage::Blob.find_signed(signed_id)
      next unless blob

      # Photoモデルがある設計前提（post.photos.create! で紐付け）
      post.photos.create!(image: blob)
    end
  end

  def clear_pending_images_session!
    session.delete(PostsController::SESSION_KEY)
  end
end
