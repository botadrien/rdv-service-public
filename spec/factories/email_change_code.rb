FactoryBot.define do
  sequence(:email_change_code_new_email) { |n| "nouvelle_adresse_#{n}@lapin.fr" }

  factory :email_change_code do
    user
    new_email { generate(:email_change_code_new_email) }
    code { SecureRandom.random_number(100_000..999_999).to_s }
    used_at { nil }
  end
end
