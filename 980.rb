require "rubygems"
require "dm-core"
require "dm-validations"

DataMapper.setup(:default, 'sqlite3://:memory:')

class History
  include DataMapper::Resource
  
  property :id, Serial
  
  belongs_to :ticket
  
  def save(*args)
    STDOUT.puts "%%%%%%% saving History"
    super
  end
  
end

class Ticket
  include DataMapper::Resource
  
  property :id, Serial

  property :title, String
  property :body, Text
  
  has 1, :history
  
  validates_present :title, :body
  
  before :create, :create_a_history
  
  before :save, :b_s
  after :save, :a_s
  
  def save(*args)
    STDOUT.puts "%%%%%%% saving Ticket"
    super # !> method redefined; discarding old to_datetime
  end
    
private

  def create_a_history
    STDOUT.puts "%%%%%%% creating a history"
    self.history = History.create
  end
  
  def b_s # !> private attribute?
    STDOUT.puts "$$$$ before :save"
  end
  
  def a_s
    STDOUT.puts "$$$$ after :save" # !> method redefined; discarding old prepare
  end
  
end

DataMapper.auto_migrate!

t = Ticket.create :title => "Hello", :body => "Hello as well"

puts "\n\n\n--- Now to save\n"

t.reload
t.save # => true

puts "\n\n\n--- Now to fetch the same one and watch it act differently\n"

t = Ticket.first
t.save # !> instance variable @log not initialized

puts "\n\n\n--- Now load the history and save again\n"

t.history # => #<History @id=1 @ticket_id=1>
t.save

# >> %%%%%%% saving Ticket
# >> %%%%%%% creating a history
# >> %%%%%%% saving History
# >> $$$$ before :save
# >> $$$$ after :save
# >> %%%%%%% saving History
# >> $$$$ before :save
# >> $$$$ after :save
# >> 
# >> 
# >> 
# >> --- Now to save
# >> %%%%%%% saving Ticket
# >> $$$$ before :save
# >> $$$$ after :save
# >> %%%%%%% saving History
# >> $$$$ before :save
# >> $$$$ after :save
# >> 
# >> 
# >> 
# >> --- Now to fetch the same one and watch it act differently
# >> %%%%%%% saving Ticket
# >> $$$$ before :save
# >> $$$$ after :save
# >> 
# >> 
# >> 
# >> --- Now load the history and save again
# >> %%%%%%% saving Ticket
# >> $$$$ before :save
# >> $$$$ after :save