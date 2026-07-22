RSpec.describe EmailChangeCode, type: :model do
  let(:user) { create(:user) }

  describe ".most_recent_usable_for scope" do
    before do
      create(:email_change_code, user: user, code: "112233", created_at: 10.minutes.ago, used_at: 8.minutes.ago)
      create(:email_change_code, user: user, code: "223344", created_at: 2.hours.ago)
      create(:email_change_code, user: user, code: "556677", created_at: 1.minute.ago)
      create(:email_change_code, user: user, code: "667788", created_at: 2.minutes.ago)
      create(:email_change_code, user: create(:user), code: "990099", created_at: 30.seconds.ago)
    end

    specify do
      expect(described_class.most_recent_usable_for(user: user).code).to eq("556677")
    end
  end

  describe "#set_random_code before_save callback" do
    let(:email_change_code) { described_class.new(user: user, new_email: "test@usager.fr") }

    specify do
      email_change_code.save
      expect(email_change_code.reload.code).not_to be_blank
    end
  end

  describe "validations" do
    specify do
      expect(described_class.new(user: user, new_email: "")).to be_invalid
      expect(described_class.new(user: user, new_email: "pas-un-email")).to be_invalid
      expect(described_class.new(user: user, new_email: "valide@example.fr")).to be_valid
    end
  end
end
