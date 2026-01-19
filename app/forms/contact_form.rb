class ContactForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :category, :string
  attribute :message, :string

  validates :message, presence: true, length: { maximum: 2000 }
  validates :name, length: { maximum: 50 }, allow_blank: true
  validates :category, length: { maximum: 30 }, allow_blank: true
  validates :email,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: I18n.t('errors.messages.invalid_email')
            },
            allow_blank: true

  CATEGORIES = [
    '不具合について',
    '使い方について',
    'ご要望・ご意見',
    'その他'
  ].freeze
end
