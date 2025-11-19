Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line,
           ENV['LINE_CHANNEL_ID'],
           ENV['LINE_CHANNEL_SECRET'],
           {
             scope: 'profile openid',
             bot_prompt: 'normal'
           }
end

# OmniAuth 2.x 対応：GET を許可
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true
