# ========================================
# LINE通知用のサービスクラス
# ========================================
class LineNotifier
  include Rails.application.routes.url_helpers

  require 'net/http'
  require 'uri'
  require 'json'

  # ----------------------------------------
  # LINEユーザーにFlexメッセージを送信
  # ----------------------------------------
  def push_flex_message(to, post)
    Rails.logger.info '=== LINE API 実行 (Flex) ==='
    Rails.logger.info "送信先: #{to}"
    Rails.logger.info "投稿ID: #{post.id}"

    payload = build_payload(to, post)
    send_line_request(payload)
  end

  private

  # ----------------------------------------
  # ペイロード全体を構築
  # ----------------------------------------
  def build_payload(to, post)
    {
      to: to,
      messages: [flex_message(post)]
    }
  end

  # ----------------------------------------
  # Flexメッセージ本体を構築
  # ----------------------------------------
  def flex_message(post)
    {
      type: 'flex',
      altText: "#{post.user.name}さんが新しい思い出を投稿しました📸",
      contents: flex_contents(post)
    }
  end

  def flex_contents(post)
    {
      type: 'bubble',
      hero: hero_image_section(post),
      body: body_text_section(post),
      footer: footer_button_section(post)
    }
  end

  def hero_image_section(post)
    photo = post.photos.first
    image_url = (photo.image.blob&.service_url if photo&.image&.attached?)

    {
      type: 'image',
      url: image_url || placeholder_image_url,
      size: 'full',
      aspectRatio: '16:9',
      aspectMode: 'cover'
    }
  end

  def placeholder_image_url
    'https://placehold.co/600x400?text=No+Image'
  end

  def body_text_section(post)
    {
      type: 'box',
      layout: 'vertical',
      contents: [
        title_text(post),
        user_text(post)
      ]
    }
  end

  def title_text(post)
    {
      type: 'text',
      text: post.title.presence || 'タイトルなし',
      weight: 'bold',
      size: 'md',
      wrap: true
    }
  end

  def user_text(post)
    {
      type: 'text',
      text: "#{post.user.name}さんが投稿しました",
      size: 'sm',
      color: '#888888',
      wrap: true
    }
  end

  def footer_button_section(post)
    {
      type: 'box',
      layout: 'vertical',
      spacing: 'sm',
      contents: [view_post_button(post)],
      flex: 0
    }
  end

  def view_post_button(post)
    {
      type: 'button',
      action: {
        type: 'uri',
        label: '投稿を見る',
        uri: post_url(post)
      },
      style: 'link',
      height: 'sm'
    }
  end

  # 通知内の投稿URLを生成
  def post_url(post)
    # production環境のホスト名を使用
    album_url(post.album)
  end

  def send_line_request(payload)
    uri = URI.parse('https://api.line.me/v2/bot/message/push')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = payload.to_json

    response = http.request(request)
    Rails.logger.info "LINE API レスポンス: #{response.code} #{response.body}"
    response
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV.fetch('LINE_CHANNEL_ACCESS_TOKEN', nil)}"
    }
  end
end
