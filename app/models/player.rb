class Player < ApplicationRecord
  serialize :hand
  serialize :played

  after_initialize do |player|
    player.hand= [] if player.hand == nil
  end
  after_initialize do |player|
    player.played= [] if player.played == nil
  end
  
  before_create :set_role
  before_create :set_number
  
  belongs_to :user
  belongs_to :game, counter_cache: true

  enum role: {admin: 0,guest: 1}
  enum team: {us: 0, them: 1}


  def play(card)
    raise StandardError.new("La partida no ha empezado") if self.game.waiting?
    raise StandardError.new("La ya ha terminado") if self.game.finished?
    if(self.hand.include?(card))
      self.played.push(card)
      self.hand.delete(card)      
    else
      raise StandardError.new("Debes juar una carta que esté e tu mano")
    end
  end

  def discard(card)
    raise StandardError.new("La partida no ha empezado") if self.game.waiting?
    raise StandardError.new("La ya ha terminado") if self.game.finished?
    if(self.hand.include?(card))
      self.played.push("empty")
      self.hand.delete(card)
    else
      raise StandardError.new("No puede descartar una carta que no está en su mano")
    end  
  end

  def deal
    raise StandardError.new("La partida no ha empezado") if self.game.waiting?
    raise StandardError.new("La ya ha terminado") if self.game.finished?
    if self.seat == self.game.deals
      self.game.reset_deck
      self.game.deck = self.game.deck.shuffle(random: Random.new())
      for player in self.game.players
        player.played = []
        player.hand = self.game.deck.pop(3)
        player.save
      end
      self.game.deals = (self.game.deals + 1) % self.game.size
      self.game.state = 1 if self.game.waiting?
    else
      raise StandardError.new("No es su turno para repartir")
    end
  end

  private
  
  def set_role
    if (self.game.players_count == 0)
      self.role = 0 #admin  (hay forma de hacer que sea mas visible? ej: role.admin)
      self.team = 0 #team "us"
    else
      self.role = 1 #guest 
    end
  end

  def set_number
    if (self.game.players_count == 0)
      srand()
      self.game.number = self.user.username + "#" + rand(1000).to_s    
      self.game.save
    end
  end
end
