RSpec.describe "Basic agent can view configuration read-only" do
  let!(:organisation) { create(:organisation, name: "MDS Montreuil Nord") }
  let!(:agent_admin) { create(:agent, last_name: "Zorro", first_name: "Don", admin_role_in_organisations: [organisation]) }
  let!(:agent_basic) { create(:agent, last_name: "Aaron", first_name: "Anna", basic_role_in_organisations: [organisation]) }
  let!(:lieu) { create(:lieu, organisation: organisation) }

  before do
    login_as(agent_basic, scope: :agent)
    visit authenticated_agent_root_path
  end

  it "shows a read-only Configuration hub with only Motifs/Lieux/Agents, admins listed first" do
    click_link "Configuration"
    expect_page_title("Configuration")

    expect(page).to have_link("Motifs de rendez-vous")
    expect(page).to have_link("Lieux")
    expect(page).to have_link("Agents")
    expect(page).not_to have_link("Réservation en ligne")
    expect(page).not_to have_link("Informations de l'organisation")

    click_link "Agents"
    expect_page_title("Agents")

    # the admin appears before the basic agent, even though "Aaron" sorts before "Zorro" alphabetically
    # (row text is upcased for the last name, e.g. "ZORRO Don")
    expect(page.all("tr").index { _1.text.include?(agent_admin.last_name.upcase) })
      .to be < page.all("tr").index { _1.text.include?(agent_basic.last_name.upcase) }

    within("tr", text: agent_admin.last_name.upcase) do
      expect(page).to have_content(agent_admin.email)
      expect(page).to have_content("Administrateur")
    end

    # a basic agent must not see any write action on another agent's row
    within("tr", text: agent_admin.last_name.upcase) do
      expect(page).not_to have_link("Modifier")
      expect(page).not_to have_link("Supprimer")
    end
    expect(page).not_to have_link("Ajouter un agent")
  end

  it "orients the agent towards the organisation admin for config-related contact reasons" do
    click_link "Aide et support"
    click_link "Formulaire de contact"

    choose("Gérer les agents de mon organisation (ajout, suppression, droits)", allow_label_click: true)
    click_button "Valider"

    expect(page).to have_content("gérée par l'administrateur de votre organisation")
    click_link "Voir les administrateurs de MDS Montreuil Nord"
    expect_page_title("Agents")
  end

  it "still lets the agent reach the support contact form for other reasons" do
    click_link "Aide et support"
    click_link "Formulaire de contact"

    choose("Autre raison", allow_label_click: true)
    click_button "Valider"

    expect(page).to have_selector("h1", text: "Formulaire de contact")
    expect(page).to have_field("La raison de votre message", with: "Autre raison")
  end
end
