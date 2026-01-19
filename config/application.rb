require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tsumugi
  class Application < Rails::Application
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.default_locale = :ja

    config.autoload_paths << Rails.root.join("app/queries")
    config.eager_load_paths << Rails.root.join("app/queries")

    # app/formsディレクトリをautoload_pathsに追加
    config.autoload_paths += %W[
      #{config.root}/app/forms
    ]
  end
end
