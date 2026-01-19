class ContactMailer < ApplicationMailer
  def user_inquiry(contact_form)
    @contact = contact_form

    mail(
      to: ENV.fetch('CONTACT_TO_EMAIL', nil),
      subject: "【Tsumugi】お問い合わせ（#{@contact.category.presence || '未選択'}）"
    )
  end
end
