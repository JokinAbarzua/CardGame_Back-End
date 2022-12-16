require "jwt"

module JsonWebToken

    extend ActiveSupport::Concern

    SECRET_KEY = Rails.application.secrets.secret_key_base

    def self.jwt_encode(payload, exp = 12.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY)
    end

    def self.jwt_decode(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]
        HashWithIndifferentAccess.new decoded
    end
    
end