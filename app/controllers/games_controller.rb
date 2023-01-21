class GamesController < ApplicationController    
    #GET    /games                                                                                  
    def index
        @games = Game.all
        render json:{status: 200, users: @games}
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
        
        if @game.persisted?
            render json: {status: :ok, game: generate_game_response, my_hand: @game.players.find_by(user_id: @current_user.id).hand}
        else
            render json:{status: 400, message: @game.error.details}
        end                    
    end
    #GET    /games/:id                                                                              
    def show
        params.require(:id)
        @game = Game.find_by(id: params[:id])
        if @game.present?
            render json:{status: :ok, game: @game}
        else
            render json:{status: 400, message: "Game not found"}
        end
    end
    #PATCH  /games/:id                                                                              
    def update
        params.require(:id)
        @game = Game.find_by(id: params[:id])
        if @game.present?
            @game.update(game_params)
            render json:{status: :ok, game: @game}
        else
            render json:{status: 400, message: "Game not found"}
        end
    end
    #DELETE /games/:id                                                                              
    def destroy

    end

    def join
        params.require([:number,:team])
        message = ""        
        @game = Game.find_by(number: params[:number])
        if @game.present?            
            for user in @game.users
                if @current_user == user
                    message = message + " User is already in the game. "
                    break
                end
            end
            if message.empty?
                message = message + " Game has already started. " if @game.state == 1
                message = message + " Game has already finished. " if @game.state == 2
                message = message + " Game is already full. " if @game.players_count >= @game.size                         
            end
            
            if params[:team] == "us" || params[:team] == "0"
                message = message + "The team us is already full" if @game.us_count == @game.size / 2
            else
                message = message + "The team them is already full" if @game.players_count - @game.us_count == @game.size / 2
            end               
            
            if message.empty?                      
                @game.users << @current_user
                if params[:team] == "us" || params[:team] == "0"
                    @game.players.find_by(user_id: @current_user.id).update(team: 0)  #equipo us  
                    @game.us_count += 1
                    if !@game.save
                        render json:{status: 500, message: "Error at DataBase update"}
                        return
                    end
                else
                    @game.players.find_by(user_id: @current_user.id).update(team: 1)  #equipo them
                    if !@game.save
                        render json:{status: 500, message: "Error at DataBase update"}        
                        return
                    end
                end
                render json:{status: :ok, game: generate_game_response, my_hand: @game.players.find_by(user_id: @current_user.id).hand}
            else
                render json:{status: 400, message: message}
            end
        else
            render json:{status: 400, message: "Game not found"}
        end
    end

    def deal        
        params.require(:number)
        @game = Game.find_by(number: params[:number])
        if @game.present?
            if @game.players_count % 2 == 0 && @game.users[@game.deals] == @current_user #hay una cantidad par de jugadores y el juador que esta pidiendo repartir tiene el turno de repartir
                @game.reset_deck
                @game.deck = @game.deck.shuffle(random: Random.new())
                for player in @game.players
                    player.played = []
                    player.hand = @game.deck.pop(3)                    
                    player.save
                end
                @game.deals = (@game.deals + 1) % @game.players_count
                @game.state = 1 if @game.waiting? #status started si estaba en waiting
                if @game.save
                    render json:{status: :ok, game: generate_game_response, my_hand: @game.players.find_by(user_id: @current_user.id).hand}
                else
                    render json:{status: 500, message: "Error at DataBase update"}
                end                
            else
                render json:{status: 400, message: "It's not your turn to deal or there are not enough players"}
            end
        else
            render json:{status: 400, message: "Game not found"}
        end
    end

    def play
        params.require([:number,:card])
        @game = Game.find_by(number: params[:number])
        if @game.present?            
            player = @game.players.find_by(user_id: @current_user.id) #es riesgoso para sql injection?
            if player.present?                
                if player.hand.include? params[:card]
                    player.played.push(params[:card])
                    player.hand.delete(params[:card])
                    if !player.save #esto creo que se puede hacer con rescue
                        render json:{status: 500, message: "Error at DataBase update"}
                    else
                        render json:{status: :ok, game: generate_game_response, my_hand: player.hand}
                    end
                else
                    render json:{status: 400, message: "Must play a card on your hand" }    
                end
            else
                render json:{status: 400, message: "Must join the game first"}
            end
        else
            render json:{status: 400, message: "Game not found"}
        end
    end

    def add_point
        params.require([:number,:team])
        
            @game = Game.find_by(number: params[:number])
            if @game.present?
                if @game.players.find_by(user_id: @current_user.id).admin?
                    if params[:team] == "us" || params[:team] == 0
                        @game.points_us += 1
                    else
                        @game.points_them += 1
                    end
                    if !@game.save
                        render json:{status: 500, message: "Error at DataBase update"}
                        return
                    end
                    render json:{status: :ok, game: generate_game_response, my_hand: @game.players.find_by(user_id: @current_user.id).hand}
                else
                    render json:{status: :forbbiden, message: "You must be admin to add points"}
                end
            else
                render json:{status: 400, message: "Game not found"}
            end        
    end

    def remove_point
        @game = Game.find_by(number: params[:number])
            if @game.present?
                if @game.players.find_by(user_id: @current_user.id).admin?
                    if params[:team] == "us" || params[:team] == 0
                        @game.points_us -= 1
                    else
                        @game.points_them -= 1
                    end
                    if !@game.save
                        render json:{status: 500, message: "Error at DataBase update"}
                        return
                    end
                    render json:{status: :ok, game: generate_game_response, my_hand: @game.players.find_by(user_id: @current_user.id).hand}
                else
                    render json:{status: :forbbiden, message: "You must be admin to remove points"}
                end
            else
                render json:{status: 400, message: "Game not found"}
            end
    end

    def status 
        params.require(:number)
        @game = @current_user.games.find_by(number: params[:number])
        if @game.present?
            render json:{status: :ok, game: generate_game_response, my_hand: @game.players.find_by(user_id: @current_user.id).hand}
        else
            render json:{status: 400, message: "Game not found"}
        end
    end

    private
    
        def game_params
            params.require(:game).permit(:size)
        end

        def generate_game_response

            json = @game.as_json(except: [:deck, :updated_at, :id], include: { players: {
                    except: [:hand, :created_at, :updated_at, :id, :user_id, :game_id], include: {
                        user: {only: :username}
                    }
            }})
        end
end

