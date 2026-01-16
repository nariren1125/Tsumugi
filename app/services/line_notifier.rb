# ========================================
# LINE通知用のサービスクラス
# ========================================
class LineNotifier
  require 'net/http'
  require 'uri'
  require 'json'

  # ----------------------------------------
  # テキストメッセージ送信
  # ----------------------------------------
  def push_message(to, message)
    Rails.logger.info '=== LINE API 実行 (Text) ==='
    Rails.logger.info "送信先: #{to}"
    Rails.logger.info "メッセージ: #{message}"

    payload = build_text_payload(to, message)
    send_line_request(payload)
  end

  # ----------------------------------------
  # Flexメッセージ送信（画像 + タイトル + リンク）
  # ----------------------------------------
  def push_flex_message(to, post)
    Rails.logger.info '=== LINE API 実行 (Flex) ==='
    Rails.logger.info "送信先: #{to}"
    Rails.logger.info "投稿ID: #{post.id}"

    payload = build_flex_payload(to, post)
    send_line_request(payload)
  end

  private

  # ----------------------------------------
  # テキストメッセージ用ペイロード構築
  # ----------------------------------------
  def build_text_payload(to, message)
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

  # ----------------------------------------
  # Flexメッセージ用ペイロード構築
  # ----------------------------------------
  def build_flex_payload(to, post)
    {
      to: to,
      messages: [flex_message(post)]
    }
  end

  # ----------------------------------------
  # Flexメッセージ本体の内容
  # ----------------------------------------
  def flex_message(post)
    {
      type: 'flex',
      altText: "#{post.user.name}さんが新しい思い出を投稿しました📸",
      contents: {
        type: 'bubble',
        hero: hero_image_section(post),
        body: body_text_section(post),
        footer: footer_button_section(post)
      }
    }
  end

  # ----------------------------------------
  # HERO画像（上部）セクション
  # ----------------------------------------
  def hero_image_section(post)
    {
      type: 'image',
      url: post.photos.first&.image&.service_url || placeholder_image,
      size: 'full',
      aspectRatio: '16:9',
      aspectMode: 'cover'
    }
  end

  # ----------------------------------------
  # 本文（タイトル + 投稿者）セクション
  # ----------------------------------------
  def body_text_section(post)
    [
      {
        type: 'text',
        text: post.title.presence || 'タイトルなし',
        weight: 'bold',
        size: 'md',
        wrap: true
      },
      {
        type: 'text',
        text: "#{post.user.name}さんが投稿しました",
        size: 'sm',
        color: '#888888',
        wrap: true
      }
    ].yield_self do |contents|
      {
        type: 'box',
        layout: 'vertical',
        contents: contents
      }
    end
  end

  # ----------------------------------------
  # フッター（リンクボタン）セクション
  # ----------------------------------------
  def footer_button_section(post)
    {
      type: 'box',
      layout: 'vertical',
      spacing: 'sm',
      contents: [
        {
          type: 'button',
          style: 'link',
          height: 'sm',
          action: {
            type: 'uri',
            label: '投稿を見る',
            uri: "https://tumugi.app/posts/#{post.id}"
          }
        }
      ],
      flex: 0
    }
  end

  # ----------------------------------------
  # プレースホルダー画像URL
  # ----------------------------------------
  def placeholder_image
    'https://placehold.co/600x400?text=No+Image'
  end

  # ----------------------------------------
  # LINE API リクエスト送信処理
  # ----------------------------------------
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

  # ----------------------------------------
  # LINE API 共通ヘッダー
  # ----------------------------------------
  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV.fetch('LINE_CHANNEL_ACCESS_TOKEN', nil)}"
    }
  end
end
