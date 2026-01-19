class InviteToken < ApplicationRecord
  belongs_to :family_group

  before_create :generate_token_and_expiry

  scope :valid, -> { where('expires_at > ?', Time.current) }

  private

  # 招待トークンと有効期限を生成
  def generate_token_and_expiry
    self.token ||= SecureRandom.urlsafe_base64(24)
    self.expires_at ||= 24.hours.from_now
  end
end
