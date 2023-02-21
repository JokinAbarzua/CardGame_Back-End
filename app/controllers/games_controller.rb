class GamesController < ApplicationController
    
    before_action :set_game, only: [:add_point, :remove_point, :status, :play, :deal,:join,:discard,:end_game]
    before_action :set_player, only: [:play,:deal,:discard]

    #GET    /games                                                                                  
    def index
        @games = @current_user.games.where(:state => [0,1]).order("created_at DESC")
        render json:{status: 200, data:{games: @games.as_json(only: [:number,:state,:created_at,:points_us,:points_them,:size])}}
    end
    #POST   /games
    def create    
        params.require(:size)                
        if params[:size].to_i <= 2 
            @game = @current_user.games.create(size: 2)    
        else
            if params[:size].to_i <= 4
                @game = @current_user.games.create(size: 4)
            else
                @game = @current_user.games.create(size: 6)
            end
        end
        @game.players[0].seat = 0        
        save_game
    end
    #GET    /games/:id                                                                              
    def show
        params.require(:id)
        @game = Game.find_by(id: params[:id])
        if @game.present?
            render json:{status: 200, data: {game: @game}}
        else
            render json:{status: 400, data: {message: "Game not found"}}
        end
    end
    #PATCH  /games/:id
    def update
        params.require(:id)
        @game = Game.find_by(id: params[:id])
        if @game.present?
            @game.update(game_params)
            render json:{status: 200, data: {game: @game}}
        else
            render json:{status: 400, data: {message: "Game not found"}}
        end
    end
    #DELETE /games/:id                                                                              
    def destroy

    end

    def join
        params.require([:team])
        begin
            @game.join(@current_user,params[:team])
            save_game
        rescue StandardError => e
            render json:{status: 400, data: {message: e.message}}
        end                
    end

    def deal        
        params.require(:number)
        if @game.is_full?
            begin
                @player.deal
                save_game
            rescue StandardError => e
                render json:{status: 400, data: {message: e.message}}
            end                  
        else
            render json:{status: 400, data: {message: "No hay suficientes jugadores para comenzar la partida"}}
        end        
    end

    def play
        params.require([:card])
        begin
            @player.play(params[:card])
            if @player.save
                render json:{status: 200, data: {game: generate_game_response, hand: @player.hand}}                
            else
                render json:{status: 500, data: {message: "Error at DataBase update"}}
            end
        rescue StandardError => e
            render json:{status: 400, data: {message: e.message}}
        end
    end

    def discard
        params.require([:card])
        begin
            @player.discard(params[:card])
            if @player.save
                render json:{status: 200, data: {game: generate_game_response, hand: @player.hand}}                
            else
                render json:{status: 500, data: {message: "Error at DataBase update"}}
            end                    
        rescue StandardError => e
            render json:{status: 400, data: {message: e.message}}
        end
    end

    def add_point
        params.require([:team])                            
        if @game.players.find_by(user_id: @current_user.id).admin?
            begin
                @game.add_point(params[:team])    
            rescue StandardError => e
                render json:{status: 400, data: {message: e.message}}
                return
            end
            save_game
        else
            render json:{status: :forbbiden, data: {message: "Debes ser admin para añadir puntos"}}
        end        
    end

    def remove_point
            params.require([:team]) 
            if @game.players.find_by(user_id: @current_user.id).admin?
                begin                    
                    @game.remove_point(params[:team])
                    save_game
                rescue StandardError => e
                    render json:{status: 400, data: {message: e.message}}    
                end                     
            else
                render json:{status: :forbbiden, data: {message: "Debes ser admin para quitar puntos"}}
            end            
    end

    def status                 
        render json:{status: 200, data: {game: generate_game_response, hand: @game.players.find_by(user_id: @current_user.id).hand}}        
    end

    def end_game
        if @game.players.find_by(user_id: @current_user.id).admin?
            begin
                @game.end_game()
                save_game
                @game.destroy!
            rescue StandardError => e
                render json:{status: 400, data: {message: e.message}}
            end                     
        else
            render json:{status: :forbbiden, data: {message: "Debes ser admin para terminar la partida"}}
        end

    end

    private
    
        def game_params
            params.require(:game).permit(:size)
        end

        def generate_game_response
            json = @game.as_json(except: [:deck, :updated_at, :id,:us_count], include: { players: {
                    except: [:hand, :created_at, :updated_at, :id, :user_id, :game_id], include: {
                        user: {only: :username}
                    }
            }})
        end

        def set_game
            params.require([:number])
            @game = Game.find_by(number: params[:number])
            if (!@game.present?)
                render json:{status: 400, data: {message: "No se ha encontrado el juego"}}
                return
            end           
        end        

        def set_player
            @player = @game.players.find_by(user_id: @current_user.id) 
            if !@player.present?
                render json:{status: 400, data: {message: "Debes ingresar al juego primero"}}
            end            
        end

        def save_game
            if @game.save
                render json:{status: 200, data: {game: generate_game_response, hand: @game.players.find_by(user_id: @current_user.id).hand}}
            else
                render json:{status: 500, data: {message: "Error at DataBase update"}}
            end
        end
end

