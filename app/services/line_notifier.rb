# frozen_string_literal: true

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

  # ----------------------------------------
  # LINEユーザーにテキストメッセージを送信
  # ----------------------------------------
  def push_text_message(to, text)
    Rails.logger.info '=== LINE API 実行 (Text) ==='
    Rails.logger.info "送信先: #{to}"

    payload = {
      to: to,
      messages: [
        { type: 'text', text: text }
      ]
    }

    send_line_request(payload)
  end

  private

  # ----------------------------------------
  # URL生成のデフォルト（Service内でも *_url が落ちない保険）
  # ----------------------------------------
  def default_url_options
    Rails.application.routes.default_url_options.presence || {
      host: ENV.fetch('APP_HOST', 'tumugi.app'),
      protocol: 'https'
    }
  end

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
      footer: footer_button_section
    }
  end

  # ----------------------------------------
  # Hero画像
  # ----------------------------------------
  def hero_image_section(post)
    {
      type: 'image',
      url: hero_image_url(post),
      size: 'full',
      aspectRatio: '16:9',
      aspectMode: 'cover'
    }
  end

  def hero_image_url(post)
    photo = post.photos.first
    return placeholder_image_url unless photo&.image&.attached?

    rails_blob_url(photo.image) # host/protocol は default_url_options に任せる
  end

  def placeholder_image_url
    'https://placehold.co/600x400?text=No+Image'
  end

  # ----------------------------------------
  # Body
  # ----------------------------------------
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
      text: "#{post.user.name}さんが思い出を投稿しました",
      size: 'sm',
      color: '#888888',
      wrap: true
    }
  end

  # ----------------------------------------
  # Footer（ボタン）
  # ----------------------------------------
  def footer_button_section
    {
      type: 'box',
      layout: 'vertical',
      spacing: 'sm',
      contents: [view_album_button],
      flex: 0
    }
  end

  def view_album_button
    {
      type: 'button',
      action: {
        type: 'uri',
        label: 'アルバムを開く',
        uri: line_entry_url(next: albums_path)
      },
      style: 'link',
      height: 'sm'
    }
  end

  # （必要なら）通知内の投稿URL生成
  def post_url_for(post)
    post_url(post)
  end

  # ----------------------------------------
  # LINE API送信
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

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV.fetch('LINE_CHANNEL_ACCESS_TOKEN')}"
    }
  end
end
