#!/usr/bin/ruby
require "rubygems"
require "dm-core"
require "spec"
require "dm-sweatshop"
DataMapper.setup(:default, 'sqlite3::memory:')

class Player
  include DataMapper::Resource
  
  property :id,    Serial

  has n, :game_memberships
  has n, :games, :through => :game_memberships

end

class Game
  include DataMapper::Resource
  
  property :id,    Serial

  has n, :game_memberships
  has n, :players, :through => :game_memberships

  def join(player)
    players << player
    save
  end
end

class GameMembership
  include DataMapper::Resource
  
  property :id,    Serial

  belongs_to :game
  belongs_to :player
end

DataMapper.auto_migrate!

class Game
  def self.gen_full_game
    game = new
    game.save
    10.times do
      p = Player.gen
      game.join p
    end
    game.save
    game
  end
end

Player.fix {{ }}

players = 5.of{Player.gen}
game = Game.gen_full_game

players.each do |player|
  game.join player
end

describe 'Game' do
  it 'should have five GameMembership' do
    GameMembership.all.reload
    game.game_memberships.size.should == 5
  end
end