# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.assets.compile = false
  config.active_storage.service = :amazon
  config.force_ssl = true

  config.logger = ActiveSupport::Logger.new($stdout)
    .tap { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [:request_id]
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  config.action_mailer.perform_caching = false

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]

  # ==================================================
  # URL生成（*_url / ActiveStorage / LINE通知など）のための host 設定
  # - APP_HOST は "tumugi.app"（https無し）を想定
  # ==================================================
  app_host = ENV.fetch('APP_HOST', 'tumugi.app')

  # url_helpers.root_url などが参照するのは routes 側なのでここが重要
  Rails.application.routes.default_url_options[:host] = app_host
  Rails.application.routes.default_url_options[:protocol] = 'https'

  # controller で url_for / rails_blob_url 等を生成する時のデフォルト
  config.action_controller.default_url_options = {
    host: app_host,
    protocol: 'https'
  }

  # mailer 内で *_url を生成する時のデフォルト
  config.action_mailer.default_url_options = {
    host: app_host,
    protocol: 'https'
  }

  # ==================================================
  # ActionMailer（SMTP）
  # ==================================================
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS'),
    port: ENV.fetch('SMTP_PORT', 587).to_i,
    domain: ENV.fetch('SMTP_DOMAIN', nil),
    user_name: ENV.fetch('SMTP_USERNAME'),
    password: ENV.fetch('SMTP_PASSWORD'),
    authentication: :plain,
    enable_starttls_auto: true
  }
end
