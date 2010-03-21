require 'rubygems'
require 'isaac'

configure do |c|
  c.nick     = "dm-alfred"
  c.server   = "irc.freenode.net"
  c.port     = 6667
  c.verbose  = true
  c.realname = 'Alfred the datamapper butler'
  c.version  = '0.0.1'
end

helpers do
  def commands
    msg channel, "this channel, #{channel}, is awesome!"
  end
end

on :connect do
  join "#datamapper"
end

on :channel, /dm-alfred: remember example/ do
  msg channel, "hey #{nick}, how are you?"
end

on :error, 401 do
  puts "oops, seems like #{nick} isn't around."
end