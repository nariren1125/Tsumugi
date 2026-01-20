# frozen_string_literal: true

class ContactsController < ApplicationController
  def new
    @contact = ContactForm.new
  end

  def create
    @contact = ContactForm.new(contact_form_params)

    return render_invalid unless @contact.valid?

    deliver_inquiry_mail!
    redirect_to contact_path, notice: t('.sent')
  rescue StandardError => e
    Rails.logger.error("[Contact] mail delivery failed: #{e.class} #{e.message}")
    redirect_to contact_path, alert: t('.mail_failed')
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:category, :name, :email, :message)
  end

  def render_invalid
    flash.now[:alert] = t('.invalid')
    render :new, status: :unprocessable_entity
  end

  def deliver_inquiry_mail!
    ContactMailer.user_inquiry(@contact).deliver_now
  end
end
