class EmailChangeCodeValidator
  # dans ce service on distingue 2 EmailChangeCodes :
  # - `usable` : moins de 30 minutes et pas utilisé, peut servir à confirmer le changement d'email
  # - `matching` : celui qui correspond au code saisi par l’usager et a moins de 24h

  def initialize(user:, code:)
    @user = user
    @code = code
  end

  def valid?
    matching_code&.usable?
  end

  def valid_email_change_code
    matching_code if valid?
  end

  def error
    @error ||=
      if usable_code_exists?
        "Veuillez renseigner le dernier code qui vous a été envoyé par email, ou attendre quelques instants de le recevoir"
      elsif matching_code&.used?
        "Code déjà utilisé, veuillez en demander un nouveau"
      elsif matching_code&.expired?
        "Code expiré, veuillez en demander un nouveau"
      else
        "Code invalide"
      end
  end

  def usable_code_exists?
    return @usable_code_exists if defined?(@usable_code_exists)

    @usable_code_exists = EmailChangeCode.where(user: @user).usable.any?
  end

  def should_redirect_to_code_request? = !usable_code_exists?

  private

  def matching_code
    @matching_code ||= EmailChangeCode
      .where(user: @user, code: @code)
      .where("created_at > ?", 24.hours.ago)
      .first
  end
end
