RSpec.describe Admin::Organisations::ConfigurationsController, type: :controller do
  let!(:organisation) { create(:organisation) }

  before do
    request.env["devise.mapping"] = Devise.mappings[:agent]
  end

  describe "GET #show" do
    subject { get :show, params: { organisation_id: organisation.id } }

    context "basic agent of the organisation" do
      let!(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before { sign_in agent }

      it "is successful" do
        subject
        expect(response).to be_successful
      end
    end

    context "admin agent of the organisation" do
      let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

      before { sign_in agent }

      it "is successful" do
        subject
        expect(response).to be_successful
      end
    end

    context "agent not in the organisation" do
      let!(:agent) { create(:agent, basic_role_in_organisations: [create(:organisation)]) }

      before { sign_in agent }

      it "redirects, unauthorized" do
        subject
        expect(response).to redirect_to(authenticated_agent_root_url)
      end
    end
  end
end
