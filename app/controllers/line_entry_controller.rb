class LineEntryController < ApplicationController
  skip_before_action :require_line_entry

  def entry
    # ✅ リッチメニュー経由の「入場券」を付与
    session[:line_entry_verified] = true
    redirect_to root_path
  end

  def blocked
    # 案内ページを表示するだけ
  end
end
