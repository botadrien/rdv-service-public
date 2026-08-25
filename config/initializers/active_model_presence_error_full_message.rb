# Par défaut, Rails ne permet de personnaliser le patron `errors.format` que par attribut,
# jamais par type d'erreur (:blank vs :taken vs :invalid, etc.). Pour afficher
# "Le champ X doit être renseigné" sur toute erreur de présence, quel que soit l'attribut,
# sans perdre les formulations déjà personnalisées (ex. "L'horaire du RDV doit être renseigné"),
# on surcharge ActiveModel::Error#full_message en se basant sur le type de l'erreur.
module ActiveModelPresenceErrorFullMessage
  PRESENCE_TYPES = %i[blank empty].freeze

  def full_message
    return super unless PRESENCE_TYPES.include?(type) && attribute != :base
    return super if scoped_translation_exists?

    "Le champ #{humanized_attribute} #{message}"
  end

  private

  def humanized_attribute
    default_name = attribute.to_s.remove(/\.base\z/).tr(".", "_").humanize
    base.class.human_attribute_name(attribute, default: default_name, base: base)
  end

  def scoped_translation_exists?
    return false unless base.class.respond_to?(:i18n_scope)

    scope = "#{base.class.i18n_scope}.errors.models"
    keys = base.class.lookup_ancestors.flat_map do |klass|
      [
        :"#{scope}.#{klass.model_name.i18n_key}.attributes.#{attribute}.format",
        :"#{scope}.#{klass.model_name.i18n_key}.format",
        :"#{scope}.#{klass.model_name.i18n_key}.attributes.#{attribute}.#{type}",
        :"#{scope}.#{klass.model_name.i18n_key}.#{type}",
      ]
    end
    keys << :"errors.attributes.#{attribute}.#{type}"

    keys.any? { |key| I18n.exists?(key, :fr) }
  end
end

ActiveModel::Error.prepend(ActiveModelPresenceErrorFullMessage)

# `ActiveModel::Errors#full_message(attribute, message)` (utilisé par exemple par le helper
# `errors_full_messages` de `app/helpers/application_helper.rb`, à la base du bandeau d'erreurs
# `_model_errors.html.slim` affiché sur la quasi-totalité des formulaires admin) appelle
# directement `ActiveModel::Error.full_message` (méthode de classe), en court-circuitant
# `ActiveModel::Error#full_message` (méthode d'instance) et donc la surcharge ci-dessus.
# On retrouve l'objet Error correspondant pour repasser par sa méthode d'instance patchée.
module ActiveModelErrorsFullMessageWithType
  def full_message(attribute, message)
    matching_error = find { |error| error.attribute == attribute && error.message == message }
    return matching_error.full_message if matching_error

    super
  end
end

ActiveModel::Errors.prepend(ActiveModelErrorsFullMessageWithType)
