class InviteToken < ApplicationRecord
  belongs_to :family_group

  before_create :generate_token_and_expiry

  scope :valid, -> { where('expires_at > ?', Time.current) }

  # ActiveAdmin / Ransack 対応（検索可能カラムの明示）
  def self.ransackable_attributes(auth_object = nil)
    %w[id token family_group_id expires_at created_at updated_at] & column_names
  end
  
  # 関連で検索を許可するならここも（必要最低限）
  def self.ransackable_associations(auth_object = nil)
    %w[family_group] & reflect_on_all_associations.map(&:name).map(&:to_s)
  end

  private

  # 招待トークンと有効期限を生成
  def generate_token_and_expiry
    self.token ||= SecureRandom.urlsafe_base64(24)
    self.expires_at ||= 24.hours.from_now
  end
end
