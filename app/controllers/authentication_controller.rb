class AuthenticationController < ApplicationController   
    include JsonWebToken
    skip_before_action :authenticate, only: [:login]

    #POST /auth/login
    def login
        @user = User.find_by(username: params[:username])
        if @user&.authenticate(params[:password]) #el metodo authenticate es de bcrypt
            token = JsonWebToken.jwt_encode(user_id: @user.id)
            if(!@user.avatar.signed_id.nil?)
                @avatar = rails_blob_path(@user.avatar)
                render json:{status: 200, data: {token:token, user: @user.as_json( except: [:password_digest, :created_at, :updated_at]).merge({"avatar"=> @avatar})}}
            else
                render json:{status: 200, data: {token:token, user: @user.as_json( except: [:password_digest, :created_at, :updated_at])}}
            end
        else
            render json:{status: 401, data: {message: "Usuario o Contraseña Invalidos"}} 
        end
    end
end
