require 'rubygems'
require 'dm-core'

class Host

	include DataMapper::Resource
	property :ip, Text, :key => true
	has n, :logs, :parent_key => [:ip], :child_key => [:source_ip]

end

class Log

	include DataMapper::Resource
	property :id, Serial
	belongs_to :source, 'Host', :parent_key => [:ip], :child_key => [:source_ip], :required => false 

	def initialize(str)
		host = Host.new
		host.ip = "1.2.3.4"
		host.save
		self.source = host
	end

end

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

Log.new("foobar").save

__END__

ree-1.8.7-2010.01 mungo:snippets snusnu$ ruby scroufal.rb 
 ~ (0.000038) SELECT sqlite_version(*)
 ~ (0.000058) DROP TABLE IF EXISTS "hosts"
 ~ (0.000013) DROP TABLE IF EXISTS "logs"
 ~ (0.000010) PRAGMA table_info("hosts")
 ~ (0.000225) CREATE TABLE "hosts" ("ip" TEXT NOT NULL, PRIMARY KEY("ip"))
 ~ (0.000009) PRAGMA table_info("logs")
 ~ (0.000156) CREATE TABLE "logs" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "source_ip" VARCHAR(65535))
 ~ (0.000080) CREATE INDEX "index_logs_source" ON "logs" ("source_ip")
 ~ (0.000036) INSERT INTO "hosts" ("ip") VALUES ('1.2.3.4')
 ~ (0.000036) INSERT INTO "logs" ("source_ip") VALUES ('1.2.3.4')
