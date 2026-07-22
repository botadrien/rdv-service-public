class Users::EmailChangeRequestsController < UserAuthController
  layout "application_base"

  before_action :ensure_can_change_email
  before_action { authorize(current_user, :update?, policy_class: User::UserPolicy) }

  def new
    @login_code = LoginCode.new
  end

  def create
    @login_code = LoginCode.new(email: login_code_params[:email], domain_id: current_domain.id)
    @email_change_request_form = Users::EmailChangeRequestForm.new(@login_code, current_user: current_user)

    if @email_change_request_form.save
      Users::EmailChangeMailer.with(login_code: @login_code).confirmation_code.deliver_later
      redirect_to new_email_change_confirmation_path(email: @login_code.email),
                  flash: { success: "Un code de confirmation a été envoyé à #{@login_code.email}." }
    else
      render :new
    end
  end

  private

  def ensure_can_change_email
    return if current_user.can_change_email?

    redirect_to users_informations_path, flash: { error: "Vous ne pouvez pas modifier votre adresse email." }
  end

  def login_code_params
    params.require(:login_code).permit(:email)
  end
end
