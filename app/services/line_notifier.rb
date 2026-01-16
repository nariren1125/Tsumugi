# ========================================
# LINE通知用のサービスクラス
# ========================================
class LineNotifier
  require 'net/http'
  require 'uri'
  require 'json'

  # 指定したLINEユーザーにメッセージを送信する
  def push_message(to, message)
    Rails.logger.info "=== LINE API 実行 ==="
    Rails.logger.info "送信先: #{to}"
    Rails.logger.info "メッセージ: #{message}"

    uri = URI.parse('https://api.line.me/v2/bot/message/push')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = build_payload(to, message).to_json

    http.request(request)

    Rails.logger.info "LINE API レスポンス: #{response.code} #{response.body}"
  end

  private

  # LINE Messaging API に必要なリクエストヘッダーを定義
  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV.fetch('LINE_CHANNEL_ACCESS_TOKEN', nil)}"
    }
  end

  # LINE APIに送るためのJSON形式のリクエストボディを構築
  def build_payload(to, message)
    {
      to: to,
      messages: [
        {
          type: 'text',
          text: message
        }
      ]
    }
  end
end
