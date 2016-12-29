class User < ApplicationRecord
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_username
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable, :authentication_keys => [:login],
         stretches: 12
  attr_writer :login

  def login
   @login || username || email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      conditions[:email].downcase!
      where(conditions).where(['username = :value OR lower(email) = lower(:value)', { value: login }]).first
    end
  end

  def validate_username
    errors.add(:username, :invalid) if User.where(email: username).exists?
  end
end
