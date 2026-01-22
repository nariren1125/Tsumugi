class LineEntryController < ApplicationController
  skip_before_action :require_line_entry

  def entry
    Rails.logger.warn("[LineEntry] entry called next=#{params[:next].inspect}")

    # リッチメニュー経由の「入場券」を付与
    session[:line_entry_verified] = true

    next_path = safe_next_path(params[:next])
    redirect_to(next_path || root_path)
  end

  def blocked
    # 案内ページを表示するだけ
  end

  private

  # 外部URLへ飛ばないように安全チェック（オープンリダイレクト対策）
  def safe_next_path(value)
    return nil if value.blank?
    return nil unless value.start_with?('/') # 相対パスのみ許可

    value
  end
end
