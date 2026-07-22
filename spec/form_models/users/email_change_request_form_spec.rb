RSpec.describe Users::EmailChangeRequestForm, type: :form_model do
  let(:user) { create(:user, email: "ancienne@adresse.fr") }

  context "la nouvelle adresse est valide et différente de l'actuelle" do
    it "le form est valide et la sauvegarde créé le login_code" do
      form = described_class.new(LoginCode.new(email: "nouvelle@adresse.fr", domain_id: "RDV_SERVICE_PUBLIC"), current_user: user)
      expect(form).to be_valid
      expect { form.save }.to change(LoginCode, :count).by(1)
    end
  end

  context "la nouvelle adresse est identique à l'adresse actuelle" do
    it "le form est invalide" do
      form = described_class.new(LoginCode.new(email: "ancienne@adresse.fr"), current_user: user)
      expect(form).not_to be_valid
      expect(form.errors[:base]).to include("La nouvelle adresse email doit être différente de l’adresse actuelle")
    end
  end

  context "la nouvelle adresse a une casse différente de l'adresse actuelle" do
    it "le form est invalide" do
      form = described_class.new(LoginCode.new(email: "ANCIENNE@adresse.fr"), current_user: user)
      expect(form).not_to be_valid
      expect(form.errors[:base]).to include("La nouvelle adresse email doit être différente de l’adresse actuelle")
    end
  end

  context "email invalide (format incorrect)" do
    specify "le form est invalide" do
      form = described_class.new(LoginCode.new(email: "pas-un-email"), current_user: user)
      expect(form).not_to be_valid
      expect { form.save }.not_to change(LoginCode, :count)
    end
  end

  context "un code a été généré très récemment pour cette adresse" do
    before { create(:login_code, email: "nouvelle@adresse.fr", created_at: 10.seconds.ago) }

    it "ne génère pas un nouveau code et affiche une erreur" do
      form = described_class.new(LoginCode.new(email: "nouvelle@adresse.fr"), current_user: user)
      expect(form).not_to be_valid
      expect { form.save }.not_to change(LoginCode, :count)
      expect(form.errors[:base]).to be_present
    end
  end
end
