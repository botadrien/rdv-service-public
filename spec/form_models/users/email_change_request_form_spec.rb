RSpec.describe Users::EmailChangeRequestForm, type: :form_model do
  let(:user) { create(:user, email: "ancienne@adresse.fr") }

  context "la nouvelle adresse est valide et différente de l'actuelle" do
    it "le form est valide et la sauvegarde créé l'email_change_code" do
      form = described_class.new(EmailChangeCode.new(user: user, new_email: "nouvelle@adresse.fr"))
      expect(form).to be_valid
      expect { form.save }.to change(EmailChangeCode, :count).by(1)
    end
  end

  context "la nouvelle adresse est identique à l'adresse actuelle" do
    it "le form est invalide" do
      form = described_class.new(EmailChangeCode.new(user: user, new_email: "ancienne@adresse.fr"))
      expect(form).not_to be_valid
      expect(form.errors[:base]).to include("La nouvelle adresse email doit être différente de l’adresse actuelle")
    end
  end

  context "la nouvelle adresse a une casse différente de l'adresse actuelle" do
    it "le form est invalide" do
      form = described_class.new(EmailChangeCode.new(user: user, new_email: "ANCIENNE@adresse.fr"))
      expect(form).not_to be_valid
      expect(form.errors[:base]).to include("La nouvelle adresse email doit être différente de l’adresse actuelle")
    end
  end

  context "email_change_code est invalide (format d'email incorrect)" do
    specify "le form est invalide" do
      form = described_class.new(EmailChangeCode.new(user: user, new_email: "pas-un-email"))
      expect(form).not_to be_valid
      expect { form.save }.not_to change(EmailChangeCode, :count)
    end
  end

  context "un code a été généré très récemment pour cet usager" do
    before { create(:email_change_code, user: user, created_at: 10.seconds.ago) }

    it "ne génère pas un nouveau code et affiche une erreur" do
      form = described_class.new(EmailChangeCode.new(user: user, new_email: "nouvelle@adresse.fr"))
      expect(form).not_to be_valid
      expect { form.save }.not_to change(EmailChangeCode, :count)
      expect(form.errors[:base]).to be_present
    end
  end
end
