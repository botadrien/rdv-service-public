class Users::EmailChangeMailerPreview < ActionMailer::Preview
  def confirmation_code
    email_change_code = EmailChangeCode.new(
      user: User.first || FactoryBot.build_stubbed(:user),
      new_email: "jean@moustache.fr",
      code: "394522",
      created_at: 10.minutes.ago
    )
    email_change_code.readonly!
    Users::EmailChangeMailer.with(email_change_code:, domain_id: Domain.default_domain_for_current_instance.id).confirmation_code
  end
end
