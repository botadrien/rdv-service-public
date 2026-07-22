module Users
  class EmailChangeRequestForm
    include ActiveModel::Model

    attr_reader :email_change_code

    delegate :new_email, to: :email_change_code

    validate :validate_email_change_code
    validate :validate_new_email_different, if: -> { email_change_code.valid? }
    validate :validate_not_sent_too_recently, if: -> { email_change_code.valid? }

    def initialize(email_change_code)
      @email_change_code = email_change_code
    end

    def validate_email_change_code
      errors.merge!(email_change_code) if email_change_code.invalid?
    end

    def validate_new_email_different
      return unless new_email.casecmp?(email_change_code.user.email.to_s)

      errors.add(:base, "La nouvelle adresse email doit être différente de l’adresse actuelle")
    end

    def validate_not_sent_too_recently
      if EmailChangeCode.most_recent_usable_for(user: email_change_code.user)&.very_recent?
        errors.add(:base, <<~ERROR)
          Un code a été envoyé à #{new_email} il y a moins de deux minutes.
          Vous devriez recevoir ce code d’ici peu de temps.
        ERROR
      end
    end

    def save = valid? && email_change_code.save
  end
end
