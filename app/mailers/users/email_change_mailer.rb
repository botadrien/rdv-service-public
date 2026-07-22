class Users::EmailChangeMailer < ApplicationMailer
  attr_reader :domain

  def confirmation_code
    @email_change_code = params[:email_change_code]
    @domain = Domain.find(params[:domain_id])

    mail(
      subject: "Votre code de confirmation est #{@email_change_code.code}",
      to: @email_change_code.new_email
    )
  end
end
