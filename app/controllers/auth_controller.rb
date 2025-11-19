class AuthController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']

    line_uid = auth['uid']
    display_name = auth.dig('info', 'name')

    # ユーザーを検索 or 新規作成
    user = User.find_or_create_by(line_uid: line_uid) do |u|
      u.name = display_name
    end

    session[:user_id] = user.id

    redirect_to root_path, notice: I18n.t('flash.login.success')
  end

  def failure
    redirect_to root_path, alert: I18n.t('flash.login.failure')
  end
end
