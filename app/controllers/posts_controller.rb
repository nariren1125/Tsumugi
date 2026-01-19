# ================================
# コントローラー: 投稿関連
# ================================
class PostsController < ApplicationController
  include PostsControllerSupport

  # 1投稿で扱える最大枚数
  MAX_PHOTOS = 5

  # select→prepare_uploads→new→create の間で
  # 「選択した画像の signed_id 配列」を一時保持する session キー
  SESSION_KEY = :pending_post_image_signed_ids

  # 認証
  before_action :require_login

  # 既存投稿を扱うアクションのみ @post を読み込む
  before_action :set_post, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  # new/create/edit/update/save_draft は人物タグUIに必要な情報を用意する
  before_action :set_person_context, only: %i[new create edit update save_draft]

  # ----------------------------
  # GET /posts/new
  # ----------------------------
  # ✅ 新規投稿フォーム表示（DB保存はしない）
  # session に入っている signed_id から Blob を取得してサムネ表示に使う
  def new
    signed_ids = pending_signed_ids
    return redirect_to_no_photos if signed_ids.empty?

    # 入力フォーム用（保存は create / save_draft）
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

    # 上限枚数までに制限して session に保存
    session[SESSION_KEY] = signed_ids.first(MAX_PHOTOS)

    # 入力フォームへ
    redirect_to new_post_path
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    clear_pending_photos_session
    redirect_to_no_photos
  end

  # 編集画面（既存導線）
  def edit; end

  # ----------------------------
  # POST /posts
  # ----------------------------
  # ✅ 本投稿（published）として保存
  # - Post を作る
  # - 成功したら Photo を作って blob を attach
  # - 最後に session を必ずクリア
  def create
    signed_ids = pending_signed_ids
    return redirect_to_no_photos if signed_ids.empty?

    # Postインスタンス生成（RuboCop対策で分離）
    build_post_for_create

    if save_post_and_photos?(signed_ids)
      # 通知は「失敗しても投稿自体は成功扱い」にする
      notify_family_group_members_safely(@post)
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

  # ----------------------------
  # POST /posts/save_draft
  # ----------------------------
  # ✅ 下書き保存（draft）として保存
  # - バリデーションを緩めた状態で保存できる（Post側で unless: :draft?）
  # - 写真も Photo として attach する
  def save_draft
    signed_ids = pending_signed_ids
    return redirect_to_no_photos if signed_ids.empty?

    # draft用のPost生成（RuboCop対策で分離）
    build_post_for_draft

    return handle_draft_success if save_draft_and_photos?(signed_ids)

    handle_draft_failure(signed_ids)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    handle_create_invalid_signature
  end
end
