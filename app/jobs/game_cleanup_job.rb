class GameCleanupJob < ApplicationJob
  queue_as :default

  def perform(game)
    game.destroy
  end
end
