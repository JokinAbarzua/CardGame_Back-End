class UsersController < ApplicationController
    skip_before_action :authenticate, only: [:create]
    before_action :set_user, only: [:show,:destroy, :update]
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
    
    #PUT    /users/:id
    def update
        if @user.update(user_params)
            avatar_url = rails_blob_path(@user.avatar)
            render json:{status: 200, data: {token:"", user: @user.as_json( except: [:password_digest, :created_at, :updated_at]).merge({"avatar"=> avatar_url})}}
        else
            render json:{status: 400, data: {message: @user.error.details}}
        end
    end
        

    #DELETE /users/:id  
    def destroy
        if(@user.destroy)
            render json:{status: 200, data: {message: "Usuario Eliminado con Exito"}}
        else
            render json:{status: 400, data: {message: @user.error.details}}
        end
    end
    
    

    private

        def set_user 
            @user = User.find(params[:id])
        end

        def user_params
            params.require(:user).permit(:username,:password,:avatar)
        end
end
