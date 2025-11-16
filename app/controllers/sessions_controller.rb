class SessionsController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']

    # 確認用：ログ出力
    Rails.logger.info auth.inspect

    # 一旦仮でトップへリダイレクト
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
