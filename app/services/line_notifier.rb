require 'net/http'
require 'uri'
require 'json'

class LineNotifier
  LINE_PUSH_API = 'https://api.line.me/v2/bot/message/push'

  def initialize
    @token = Rails.application.credentials.dig(:line, :access_token)
  end

  def push_message(to, message)
    uri = URI.parse(LINE_PUSH_API)
    header = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{@token}"
    }

    body = {
      to: to,
      messages: [{ type: 'text', text: message }]
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json
    response = http.request(request)

    Rails.logger.info "LINE通知：#{response.code} #{response.body}"
  end
end
