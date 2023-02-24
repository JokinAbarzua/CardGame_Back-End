class UsersController < ApplicationController
    skip_before_action :authenticate, only: [:create]
    before_action :set_user, only: [:show]
    #GET /users
    def index
        @users = User.all
        render json:{status: 200, data: {users: @users}}
    end

    #GET    /users/:id
    def show        
        render json:{status: 200, data:{user: @user}}    
    end
    
    #POST   /users
    def create
        @user = User.new(user_params)
        if @user.save
            render json:{status: 200, data: {user: @user.as_json( except: [:password_digest, :created_at, :updated_at])}}
        else
            render json:{status: 400, data: {message: @user.errors.objects.first.full_message}}
        end
        
    end
    
    #PUT    /users/
    def update        
        update = false        
        error = ""
        if !params[:user][:username].nil?             
            if User.valid_attribute?(:username,params[:user][:username],error)
                update = @current_user.update_attribute("username", params[:user][:username]) 
            else
                update = false
            end                        
        end
        if !params[:user][:password].nil?
            if User.valid_attribute?(:password,params[:user][:password],error)                
                update = @current_user.update_attribute("password", params[:user][:password])
            else
                update = false
            end                        
        end
        if !params[:user][:avatar].nil?                                 
            begin
                update = @current_user.update_avatar(params[:user][:avatar])
            rescue StandardError => e
                error = e.message
            end
        end
        if update
            if(!@current_user.avatar.signed_id.nil?)
                avatar_url = rails_blob_path(@current_user.avatar)
                render json:{status: 200, data: {token:"", user: @current_user.as_json( except: [:password_digest, :created_at, :updated_at]).merge({"avatar"=> avatar_url})}}
            else
                render json:{status: 200, data: {token:"", user: @current_user.as_json( except: [:password_digest, :created_at, :updated_at])}}
            end
        else
            render json:{status: 400, data: {message: error}}
        end        
    end
        

    #DELETE /user
    def destroy
        if(@current_user.destroy)
            render json:{status: 200, data: {message: "Usuario Eliminado con Exito"}}
        else
            render json:{status: 400, data: {message: @current_user.errors.details}}
        end
    end
    
    

    private

        def set_user 
            if User.exists?(params[:id])
                @user = User.find(params[:id])
            else
                !@user.present?
                render json:{status: 404, data: {message: "No se ha podido encontrar al usuario de id " + params[:id]}}
                return
            end
        end

        def user_params
            params.require(:user).permit(:username,:password,:avatar)
        end
end
