module Users
  class EmailChangeRequestForm
    include ActiveModel::Model

    attr_reader :login_code, :current_user

    delegate :email, to: :login_code

    validates :email, presence: true, format: { with: Devise.email_regexp }
    validate :validate_new_email_different, if: -> { errors[:email].empty? }
    validate :validate_not_sent_too_recently, if: -> { errors[:email].empty? }

    def initialize(login_code, current_user:)
      @login_code = login_code
      @current_user = current_user
    end

    def validate_new_email_different
      return unless email.casecmp?(current_user.email.to_s)

      errors.add(:base, "La nouvelle adresse email doit être différente de l’adresse actuelle")
    end

    def validate_not_sent_too_recently
      if LoginCode.most_recent_usable_for(email:)&.very_recent?
        errors.add(:base, <<~ERROR)
          Un code a été envoyé à #{email} il y a moins de deux minutes.
          Vous devriez recevoir ce code d’ici peu de temps.
        ERROR
      end
    end

    def save = valid? && login_code.save
  end
end
