class ApplicationController < ActionController::API
    include JsonWebToken
    before_action :authenticate

    private

    def authenticate
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        begin
            decoded = JsonWebToken.jwt_decode(header)        
        rescue
            render json:{status: 401, data: {message: "Su token ha expirado"}} 
            return
        end
        @current_user = User.find(decoded[:user_id])
    end
end
