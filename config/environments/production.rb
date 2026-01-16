require "active_support/core_ext/integer/time"

Rails.application.configure do

  # コードの変更をキャッシュし、パフォーマンスを向上
  config.eager_load = true

  # エラーレポートを無効化, ユーザーに詳細なエラー情報を表示しないようにするため
  config.consider_all_requests_local = false
  # キャッシュを有効化, 本番環境での高速化のため
  config.action_controller.perform_caching = true
  # 静的ファイルの配信を無効化, NGINXやApacheなどのWebサーバーに任せるため
  config.assets.compile = false
  # 本番環境ではAmazon S3を使用
  config.active_storage.service = :amazon
  # セキュリティ強化のため、すべての通信をSSLにリダイレクト
  config.force_ssl= true

  # ロギングの設定
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # リクエストIDをログに含める設定
  config.log_tags = [ :request_id ]

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.action_mailer.perform_caching = false

  config.i18n.fallbacks = true

  config.active_support.report_deprecations = false

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]

  # ActiveStorageのURL生成のために必要
  Rails.application.routes.default_url_options[:host] = 'https://tumugi.app'

end
