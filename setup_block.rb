require 'rubygems'
require 'dm-core'

module DataMapper

  # monkey patch alarm
  def self.setup(*args)

    # original code
    # ------------------------------------------------
    adapter = args.first
    
    unless adapter.kind_of?(Adapters::AbstractAdapter)
      adapter = Adapters.new(*args)
    end
    
    Repository.adapters[adapter.name] = adapter
    # ------------------------------------------------

    # make it possible to something after setup
    yield adapter if block_given?
    run_after_setup_hooks

  end

  def self.after_setup(&block)
    (@blocks ||= []) << block
  end

  private

  def self.run_after_setup_hooks
    (@blocks ||= []).each { |block| block.call(repository.adapter) }
  end

end

DataMapper.after_setup do |adapter|
  puts "XXX: adapter_class = #{adapter.class}"
end

DataMapper.setup(:default, 'sqlite3::memory') do |adapter|
  puts "XXX: adapter_name = #{adapter.name.inspect}"
end

__END__

[ree-1.8.7-2009.10] mungo:snippets snusnu$ ruby setup_block.rb 
XXX: adapter_name = :default
XXX: adapter_class = DataMapper::Adapters::Sqlite3Adapter
