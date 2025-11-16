
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line,
           ENV['LINE_CHANNEL_ID'],
           ENV['LINE_CHANNEL_SECRET'],
           {
              scope: 'profile openid',
              bot_prompt: 'normal'
            }
end
