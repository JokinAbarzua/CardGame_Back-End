class AuthenticationController < ApplicationController   
    include JsonWebToken
    skip_before_action :authenticate, only: [:login]

    #POST /auth/login
    def login
        @user = User.find_by(username: params[:username])
        if @user&.authenticate(params[:password]) #el metodo authenticate es de bcrypt
            token = JsonWebToken.jwt_encode(user_id: @user.id)
            render json:{status: 200, token:token, user: @user.as_json( except: [:password_digest, :created_at, :updated_at])}
        else
            render json:{status: 401, message: "Usuario o Contraseña Invalidos"} 
        end
    end
end
