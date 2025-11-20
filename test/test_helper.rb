ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  fixtures :all

  # 全テストで使えるログインメソッド（LINEログイン版）
  def log_in_as(user)
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new({
      provider: 'line',
      uid: user.line_uid || 'test_uid',
      info: {
        name: user.name,
        email: user.email
      }
    })

    get '/auth/line/callback'
  end
end
