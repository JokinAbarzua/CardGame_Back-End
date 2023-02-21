class AuthenticationController < ApplicationController   
    include JsonWebToken
    skip_before_action :authenticate, only: [:login]

    #POST /auth/login
    def login
        @user = User.find_by(username: params[:username])
        if @user&.authenticate(params[:password]) #el metodo authenticate es de bcrypt            
            token = JsonWebToken.jwt_encode(user_id: @user.id)
            @user.token = token
            @user.save(:validate => false)
            if(!@user.avatar.signed_id.nil?)
                @avatar = rails_blob_path(@user.avatar)
                render json:{status: 200, data: {token:token, user: @user.as_json( except: [:password_digest, :created_at, :updated_at]).merge({"avatar"=> @avatar})}}
            else
                render json:{status: 200, data: {token:token, user: @user.as_json( except: [:password_digest, :created_at, :updated_at])}}
            end
        else
            render json:{status: 403, data: {message: "Usuario o Contraseña Invalidos"}} 
        end
    end

    def logout
        @current_user.logout
        if @current_user.save(:validate => false) 
            render json:{status: 200, data: {message: "Que vuelvas pronto :)"}} 
        else
            render json:{status: 500, data: {messsage: "Error al cerrar session"}} 
        end
    end
end
