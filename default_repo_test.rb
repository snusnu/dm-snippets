require 'rubygems'
require 'dm-core'

require 'spec'
require 'spec/autorun'

class Person
  include DataMapper::Resource
  property :id, Serial
end

describe 'DataMapper.auto_upgrade!' do
  describe 'with no :default repository setup' do
    it 'should not raise an error when run for an arbitrary repository' do
      DataMapper.setup(:moneta, 'sqlite3::memory:')
      lambda { Person.auto_upgrade!(:moneta) }.should_not raise_error
    end
  end
  describe 'with a :default repository setup' do
    it 'should not raise an error when run for an arbitrary repository' do
      DataMapper.setup(:default, 'sqlite3::memory:')
      DataMapper.setup(:moneta, 'sqlite3::memory:')
      lambda { Person.auto_upgrade!(:moneta) }.should_not raise_error
    end
  end
end

__END__

mungo:snippets snusnu$ ruby default_repo_test.rb 
F.

1)
'DataMapper.auto_upgrade! with no :default repository setup should not raise an error when run for an arbitrary repository' FAILED
expected no Exception, got #<DataMapper::RepositoryNotSetupError: Adapter not set: default. Did you forget to setup?>
default_repo_test.rb:16:
default_repo_test.rb:12:

Finished in 0.067119 seconds

2 examples, 1 failure
