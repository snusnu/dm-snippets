require "rubygems"
require "dm-core"
require "dm-sweatshop"
require "spec"

#DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class GameMembership
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial

  # 
  # Associations
  #
  belongs_to :game
  belongs_to :player

end

class Player
  include DataMapper::Resource
  #
  # Properties
  #
  property :id,     Serial

  # 
  # Associations
  #
  has n, :game_memberships
  has n, :games, :through => :game_memberships

  def join(game)
    game.join(self)
  end

  def leave
    if is_playing?
      where_playing.leave(self)
      return true
    else
      return false
    end
  end

  def is_playing?
    !! where_playing
  end

  def where_playing
    games.first
  end
end

class Game
  include DataMapper::Resource
  
  #
  # Properties
  #
  property :id, Serial
  
  #
  # Associations
  #
  has n, :game_memberships
  has n, :players, :through => :game_memberships

  def join(player)
    allowed_to_join(player)
    players << player
    puts "XXX: players = #{players.inspect}"
    save
  end

  def leave(player)
    gm(player).destroy
    destroy if game_memberships.size == 0
  end

  def allowed_to_join?(player)
    begin
      allowed_to_join(player)
      true
    rescue => e
      errors.add :player, e
      false
    end
  end

  def allowed_to_join(player)
    raise PlayerPlaying, "#{player.login} is playing in #{player.where_playing.id}." if player.is_playing?
  end

  def gm(player)
    game_memberships.first(:player => player)
  end
end

Player.fix {{}}
Game.fix {{}}


def pg
  p = Player.gen
  g = Game.gen
  [p,g]
end

DataMapper.auto_migrate!

describe 'Game' do

  before(:each) do
    GameMembership.all.destroy
    Player.all.destroy
    Game.all.destroy
  end
  it 'should be possible for players to join' do
    p,g = pg
    p.join(g).should be_true # @g.join(@p) possible too
    g.players.all.include?(p).should be_true
    p.where_playing.should == g
  end

  it 'should be possible for players to leave' do
    p,g = pg
    p.join(g).should be_true
    p.leave.should be_true
    g.reload
    g.players.all.include?(p).should be_false
    p.is_playing?.should be_false
  end

  it 'should be possible to rejoin' do
    p,g = pg
    p.join(g).should be_true
    p.leave.should be_true
    g.reload
    g.players.all.include?(p).should be_false
    g.players.all.should be_empty
    p.is_playing?.should be_false
    puts "XXX: here it comes"
    p.join(g).should be_true
    g.players.all.include?(p).should be_true
    p.where_playing.should == g
  end
end
