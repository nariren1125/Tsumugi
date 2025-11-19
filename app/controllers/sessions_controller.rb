class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    # LINE UID
    line_uid = auth['uid']
    name = auth.dig('info', 'name')
    image = auth.dig('info', 'image')

    # 既存ユーザーを検索 or 作成(仮)
    user = User.find_or_create_by(line_uid: line_uid) do |u|
      u.name = name
      u.email = ""  # LINEログインではメールが取れない
    end

    # ログイン（セッションにユーザーID保存）
    session[:user_id] = user.id

    redirect_to root_path, notice: "ログインしました"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました"
  end
end
