require 'bcrypt'

module Panel
  class User
    include Mongoid:: Document

    field :nick, type: String # username
    field :salt, type: String # password digest

    attr_reader :password

    validate :password_required
    validates :password, confirmation: true, length: { minimum: 6, maximum: 20 }
    validates :nick, uniqueness: true, length: { minimum: 4, maximum: 10 }

    def self.authenticate(username, unencrypted_password)
      user = Panel::User.where(nick: username).first
      return nil unless user

      user.has_password?(unencrypted_password) ? user : nil
    end

    def has_password?(unencrypted_password)
      BCrypt::Password.new(salt) == unencrypted_password
    end

    def password=(unencrypted_password)
      if unencrypted_password.nil?
        self.salt = nil
      elsif !unencrypted_password.empty?
        @password = unencrypted_password
        self.salt = BCrypt::Password.create(unencrypted_password)
      end
    end

    def password_confirmation=(unencrypted_password)
      @password_confirmation = unencrypted_password
    end

    protected

    def password_required
      self.errors.add(:password, "can't be blank") unless self.salt.present?
    end
  end
end
