class Users::EmailChangesController < UserAuthController
  layout "application_base"

  before_action :ensure_can_change_email
  before_action { authorize(current_user, :update?, policy_class: User::UserPolicy) }

  def new
    @email_change_code = EmailChangeCode.new(user: current_user)
  end

  def create
    @email_change_code = EmailChangeCode.new(user: current_user, new_email: email_change_code_params[:new_email])
    @email_change_request_form = Users::EmailChangeRequestForm.new(@email_change_code)

    if @email_change_request_form.save
      Users::EmailChangeMailer.with(email_change_code: @email_change_code, domain_id: current_domain.id).confirmation_code.deliver_later
      redirect_to edit_email_change_path,
                  flash: { success: "Un code de confirmation a été envoyé à #{@email_change_code.new_email}." }
    else
      render :new
    end
  end

  def edit
    @existing_email_change_code = EmailChangeCode.most_recent_usable_for(user: current_user)
    redirect_to new_email_change_path unless @existing_email_change_code
  end

  def update
    validator = EmailChangeCodeValidator.new(user: current_user, code: email_change_code_params[:code])

    if validator.valid?
      valid_email_change_code = validator.valid_email_change_code
      current_user.update!(email: valid_email_change_code.new_email)
      valid_email_change_code.update!(used_at: Time.zone.now)
      redirect_to users_informations_path, flash: { success: "Votre adresse email a été mise à jour." }
    elsif validator.should_redirect_to_code_request?
      redirect_to new_email_change_path, flash: { error: validator.error }
    else
      @existing_email_change_code = EmailChangeCode.most_recent_usable_for(user: current_user)
      @existing_email_change_code.errors.add(:base, validator.error)
      render :edit
    end
  end

  private

  def ensure_can_change_email
    return if current_user.can_change_email?

    redirect_to users_informations_path, flash: { error: "Vous ne pouvez pas modifier votre adresse email." }
  end

  def email_change_code_params
    params.require(:email_change_code).permit(:new_email, :code)
  end
end
