class Game < ApplicationRecord
    serialize :deck

    after_initialize do |game|
        game.deck = [] if game.deck == nil
    end

    after_create :set_deck
    validates :number, uniqueness: true    
    has_many :players, dependent: :destroy, autosave: true
    has_many :users, through: :players

    enum state: {waiting: 0, started: 1, finished: 2}
    
    def reset_deck
        self.deck = ["e1","e2","e3","e4","e5","e6","e7","e10","e11","e12","b1","b2","b3","b4","b5","b6","b7","b10","b11","b12","o1","o2","o3","o4","o5","o6","o7","o10","o11","o12","c1","c2","c3","c4","c5","c6","c7","c10","c11","c12"]
    end
    private

    def set_deck
        self.deck = ["e1","e2","e3","e4","e5","e6","e7","e10","e11","e12","b1","b2","b3","b4","b5","b6","b7","b10","b11","b12","o1","o2","o3","o4","o5","o6","o7","o10","o11","o12","c1","c2","c3","c4","c5","c6","c7","c10","c11","c12"] if self.deck.empty?
    end
end
