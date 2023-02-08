class Game < ApplicationRecord
    serialize :deck    

    after_initialize do |game|
        game.deck = [] if game.deck == nil
    end    

    after_create :set_deck    
    validates :number, uniqueness: true 
    validates :size, presence: {message: "Debe definir la cantidad de jugadores que tendrá la partida"}
    has_many :players, -> {order('seat ASC')}, dependent: :destroy, autosave: true
    has_many :users, through: :players

    enum state: {waiting: 0, started: 1, finished: 2}
    
    def reset_deck
        self.deck = ["e1","e2","e3","e4","e5","e6","e7","e10","e11","e12","b1","b2","b3","b4","b5","b6","b7","b10","b11","b12","o1","o2","o3","o4","o5","o6","o7","o10","o11","o12","c1","c2","c3","c4","c5","c6","c7","c10","c11","c12"]
    end


    def add_point(team)
        if team == 0 || team == "us"
            self.points_us += 1
        else
            self.points_them += 1
        end
    end

    def remove_point(team)
        if team == 0 || team == "us"
            self.points_us == 0 ? false : self.points_us -= 1            
        else
            self.points_them == 0 ? false : self.points_them -= 1
        end
    end
    
    def is_full?
        self.players_count == self.size
    end

    def join(user,team)        
        raise StandardError.new("El usuario ya se encuentra en la partida") if self.players.find_by(user_id: user.id)
        raise StandardError.new("El juego ya ha empezado") if self.state == 1
        raise StandardError.new("El juego ya ha terminado") if self.state == 2
        raise StandardError.new("Game is already full") if self.players_count >= self.size        
        raise StandardError.new("El equipo \"nosotros\" ya está lleno") if self.us_count == self.size / 2 && (team == "us" || team == "0")
        raise StandardError.new("El equipo \"ellos\" ya está lleno") if self.players_count - self.us_count == self.size / 2 && (team == "them" || team == "1")
        
        self.users << user
        player = self.players.find_by(user_id: user.id)
        if team == "us" || team == "0"
            player.update(team: "us")  #equipo us
            self.us_count += 1            
            self.find_seat(player,team)        
            self.state = 1 if (self.players_count == self.size - 1  && self.waiting?)            
        else
            player.update(team: "them")  #equipo them
            self.find_seat(player,team)
            self.state = 1 if (self.players_count == self.size  && self.waiting?)            
        end
        player.save
        self.players
    end
        
    private

    def find_seat(player,team)
        if team == "us" || team == "0"
            if self.players.find_by(seat:2)                
                    player.seat = 4                
            else
                player.seat = 2
            end
        else            
            if self.players.find_by(seat:1)                
                if self.players.find_by(seat:3)
                    player.seat = 5
                else
                    player.seat = 3
                end
            else
                player.seat = 1
            end
        end        
    end

    def set_deck
        self.deck = ["e1","e2","e3","e4","e5","e6","e7","e10","e11","e12","b1","b2","b3","b4","b5","b6","b7","b10","b11","b12","o1","o2","o3","o4","o5","o6","o7","o10","o11","o12","c1","c2","c3","c4","c5","c6","c7","c10","c11","c12"] if self.deck.empty?
    end              
end