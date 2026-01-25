class AdminUser < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  # ActiveAdmin / Ransack 対応（検索可能カラムの明示）
  # 機微情報（encrypted_password, reset_password_token等）は含めない
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      email
      created_at
      updated_at
      remember_created_at
      reset_password_sent_at
    ] & column_names
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
