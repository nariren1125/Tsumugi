class ContactsController < ApplicationController
  skip_before_action :require_login, raise: false

  def new
    @contact = ContactForm.new
  end

  def create
    @contact = ContactForm.new(contact_params)

    if @contact.valid?
      ContactMailer.user_inquiry(@contact).deliver_now
      redirect_to contact_path, notice: t('.success')
    else
      flash.now[:alert] = t('.invalid')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_form).permit(:name, :email, :category, :message)
  end
end
