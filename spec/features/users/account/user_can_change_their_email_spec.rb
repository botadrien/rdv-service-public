RSpec.describe "User can change their email" do
  let!(:organisation) { create(:organisation, territory: create(:territory)) }
  let(:user) { create(:user, email: "ancienne@adresse.fr", organisations: [organisation]) }

  before { login_as(user, scope: :user) }

  it "permet de changer son adresse email via un code de confirmation à 6 chiffres" do
    visit users_informations_path
    click_link "Changer d’adresse email"

    expect(page).to have_content "Changer d’adresse email"
    fill_in "Nouvelle adresse email", with: "nouvelle@adresse.fr"
    click_on "Recevoir un code de confirmation"

    expect(page).to have_content "Un code de confirmation a été envoyé à nouvelle@adresse.fr"

    fill_in "Code à 6 chiffres", with: LoginCode.most_recent_usable_for(email: "nouvelle@adresse.fr").code
    click_on "Valider"

    expect(page).to have_content "Votre adresse email a été mise à jour."
    expect(page).to have_field("Email", with: "nouvelle@adresse.fr", disabled: true)
    expect(user.reload.email).to eq "nouvelle@adresse.fr"
  end

  context "quand l'usager est connecté via FranceConnect" do
    let(:user) { create(:user, :using_france_connect, organisations: [organisation]) }

    it "n'affiche pas le lien de changement d'adresse email et bloque l'accès direct au formulaire" do
      visit users_informations_path
      expect(page).to have_field("Email", with: user.email, disabled: true)
      expect(page).not_to have_link "Changer d’adresse email"

      visit new_email_change_path
      expect(page).to have_content "Vous ne pouvez pas modifier votre adresse email."
      expect(page).to have_current_path(users_informations_path)
    end
  end
end
