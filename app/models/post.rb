class Post < ApplicationRecord
  belongs_to :album
  belongs_to :user
  belongs_to :child, optional: true

  # 写真との関連付け（並び順を持たせる）
  has_many :photos, -> { order(:position) }, dependent: :destroy, inverse_of: :post
  # 写真に対するタグ付けとの関連付け
  has_many :post_person_tags, dependent: :destroy
  has_many :person_tags, through: :post_person_tags
  # コメントとの関連付け
  has_many :comments, dependent: :destroy

  # PostモデルがPhotoモデルの属性を受け入れるように設定
  accepts_nested_attributes_for :photos, allow_destroy: true

  # 投稿作成時にchild_idが未設定なら、関連するアルバムのchild_idで埋める
  before_validation :fill_child_id_from_album, on: :create

  # 投稿ステータス
  enum :status, { draft: 0, published: 1 }

  validates :photo_date, presence: true, unless: :draft?
  validates :title, presence: true, length: { maximum: 20 }, unless: :draft?
  validates :content, presence: true, length: { maximum: 500 }, unless: :draft?

  validate :photos_count_within_limit, unless: :draft?

  # 家族グループに属する投稿を取得するスコープ
  scope :for_family_group, lambda { |family_group|
    joins(:album).where(albums: { family_group_id: family_group.id })
  }

  # ActiveAdmin / Ransack 対応（検索可能カラムの明示）
  RANSACKABLE_ATTRIBUTES = %w[
    id
    title
    content
    status
    photo_date
    created_at
    updated_at
    user_id
    album_id
  ].freeze

  # ActiveAdmin / Ransack 対応（検索可能カラムの明示）
  def self.ransackable_attributes(_auth_object = nil)
    RANSACKABLE_ATTRIBUTES
  end

  # 関連で検索を許可するならここも（必要最低限）
  def self.ransackable_associations(_auth_object = nil)
    %w[
      album
      user
      child
      photos
      person_tags
      post_person_tags
    ] & reflect_on_all_associations.map(&:name).map(&:to_s)
  end

  private

  def photos_count_within_limit
    return unless photos.size > 5

    errors.add(:base, '写真は最大5枚まで投稿できます')
  end

  # 投稿のchild_idが未設定の場合、関連するアルバムのchild_idで埋める
  def fill_child_id_from_album
    self.child_id ||= album&.child_id
  end
end
