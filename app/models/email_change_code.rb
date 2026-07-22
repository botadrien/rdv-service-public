class EmailChangeCode < ApplicationRecord
  EXPIRE_AFTER = 30.minutes

  belongs_to :user

  scope :not_expired, -> { where("created_at > ?", EXPIRE_AFTER.ago) }
  scope :not_used, -> { where(used_at: nil) }
  scope :usable, -> { not_expired.not_used }

  validates :new_email, presence: true, format: { with: Devise.email_regexp }

  before_create :set_random_code

  def self.most_recent_usable_for(user:)
    where(user:).usable.order(created_at: :desc).first
  end

  def set_random_code
    self.code ||= SecureRandom.random_number(100_000..999_999).to_s
  end

  def expired? = created_at < EXPIRE_AFTER.ago
  def used? = used_at.present?
  def usable? = !expired? && !used?
  def very_recent? = created_at > 2.minutes.ago
end
