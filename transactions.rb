require 'dm-core'
require 'dm-transactions'

class Resource1
  include DataMapper::Resource

  property :id, Serial

end

DataMapper.setup(:default, 'sqlite3:memory:')

class Resource2
  include DataMapper::Resource

  property :id, Serial
end

p Resource1.new.methods.grep /transaction/
p Resource2.new.methods.grep /transaction/

__END__

ree-1.8.7-2010.01 mungo:dm-snippets snusnu$ bundle exec ruby transactions.rb 
[]
["transaction"]
