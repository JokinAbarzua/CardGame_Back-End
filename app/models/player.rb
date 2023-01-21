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
