require "jwt"

module JsonWebToken

    extend ActiveSupport::Concern

    SECRET_KEY = Rails.application.secrets.secret_key_base

    def self.jwt_encode(payload, exp = 6.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY)
    end

    def self.jwt_decode(token)        
        decoded = JWT.decode(token, SECRET_KEY)[0]
        JWT::ExpiredSignature                    
        HashWithIndifferentAccess.new decoded
    end
    
end