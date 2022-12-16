class UsersController < ApplicationController
    skip_before_action :authenticate, only: [:create]
    before_action :set_user, only: [:show,:destroy, :update]    
    #GET /users
    def index        
        @users = User.all
        render json:{status: 200, users: @users}
    end

    #GET    /users/:id
    def show        
        render json:{status: 200, user: @user}
    end
    
    #POST   /users
    def create
        @user = User.new(user_params)
        if @user.save
            render json:{status: 200, user: @user}
        else
            render json:{status: 400, message: @user.error.details}
        end
        
    end
    
    #PUT    /users/:id  
    def update
        
    end
    
    #DELETE /users/:id  
    def destroy
        if(@user.destroy)
            render json:{status: 200, message: "Usuario Eliminado con Exito"}
        else
            render json:{status: 400, message: @user.error.details}
        end
    end
    
    

    private

        def set_user 
            @user = User.find(params[:id])        
        end

        def user_params 
            params.require(:user).permit(:username,:password)
        end
end
