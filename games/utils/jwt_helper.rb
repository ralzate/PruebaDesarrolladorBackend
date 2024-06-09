class JwtHelper

  ENV['SESSION_EXPIRE_AFTER'] ||= '3600'
  ENV['JWT_SECRET_KEY'] ||= 'jwt_secret_key'
  ENV['JWT_CONNECTION'] ||= 'Games'

  def self.generate_token(payload)
    user_id = payload.delete(:user_id)

    additional_info = additional_jwt_fields(user_id)
    payload.merge!(additional_info)

    return JWT.encode(payload, ENV['JWT_SECRET_KEY'], 'HS256')
  end

  def self.valid_token?(token)
    options = {
      verify_expiration: true,
      verify_iat: true

    }

    begin
      JWT.decode(token, ENV['JWT_SECRET_KEY'], true, options)
    rescue JWT::DecodeError => e
      puts "Error verifying the user JWT. #{e.message} - token: #{token}"
      return false
    end

    return true
  end

  def self.calculate_expires_timestamp(issued_timestamp)
    return issued_timestamp + ENV['SESSION_EXPIRE_AFTER'].to_i
  end

  def self.additional_jwt_fields(user_id)
    issued_timestamp = Time.now.to_i

    return {
      sub: "#{ENV['JWT_CONNECTION']}|#{user_id}",
      iat: issued_timestamp,
      exp: calculate_expires_timestamp(issued_timestamp)
    }
  end
end
