require "rubygems"
require "dm-core"
require "dm-aggregates"
require "randexp"
 
module Integrity
  class Project
    include DataMapper::Resource
 
    property :id, Serial
    property :name, String, :nullable => false
 
    has n, :commits, :model => "Integrity::Commit"
  end
 
  class Commit
    include DataMapper::Resource
 
    property :id, Serial
    property :identifier, String, :nullable => false
 
    has 1, :build, :model => "Integrity::Build"
 
    belongs_to :project, :model => "Integrity::Project",
                         :child_key => [:project_id]
  end
 
  class Build
    include DataMapper::Resource
 
    property :id, Serial
    property :output, Text, :default => ""
 
    belongs_to :commit, :model => "Integrity::Commit",
                        :child_key => [:commit_id]
  end
end
 
DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.auto_migrate!
 
project = Integrity::Project.create(:name => "My Project")
# 100.times {
#   project.commits << Integrity::Commit.new(:identifier => "f59dd24",
#     :build => Integrity::Build.new(:output => /[:sentence:]/.gen))
#   project.save
# }
# idx = 0
# Integrity::Project.get(1).commits.each do |c|
#   idx += 1
#   puts "idx = #{idx}, #{c.build.output}"
# end

project = Integrity::Project.create(:name => "My Project")
5.times { |i|
  project.commits << Integrity::Commit.new(:identifier => i,
    :build => Integrity::Build.new(:output => /[:sentence:]/.gen))
  project.save
}
Integrity::Project.get(1).commits.each { |c| p c.build.output }

# performs 100 SELECTs and ends with a nil access

#  ~ (0.000030) SELECT "id", "commit_id" FROM "integrity_builds" WHERE "commit_id" = 98 ORDER BY "id" LIMIT 1
#  ~ (0.000030) SELECT "id", "output" FROM "integrity_builds" WHERE "commit_id" = 98 ORDER BY "id" LIMIT 1
# idx = 98, Tricarpellary smalt potorous superextend nonconspirator fork bookdom brasque voltameter concernment gentleship aeronat
# DataMapper::Associations::OneToMany::Collection#build is deprecated, use DataMapper::Associations::OneToMany::Collection#new instead (/opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/one_to_many.rb:152:in `send')
#  ~ (0.000029) SELECT "id", "commit_id" FROM "integrity_builds" WHERE "commit_id" = 99 ORDER BY "id" LIMIT 1
#  ~ (0.000029) SELECT "id", "output" FROM "integrity_builds" WHERE "commit_id" = 99 ORDER BY "id" LIMIT 1
# idx = 99, Gavel insatiate micropia sacerdotalize talloel saltpetrous institutionalism outweave notch tum permalloy malodorousness equal paramount histaminase sucivilized
# DataMapper::Associations::OneToMany::Collection#build is deprecated, use DataMapper::Associations::OneToMany::Collection#new instead (/opt/local/lib/ruby/gems/1.8/gems/dm-core-0.10.0/lib/dm-core/associations/one_to_many.rb:152:in `send')
#  ~ (0.000036) SELECT "id", "commit_id" FROM "integrity_builds" WHERE "commit_id" = 100 ORDER BY "id" LIMIT 1
#  ~ (0.000030) SELECT "id", "output" FROM "integrity_builds" WHERE "commit_id" = 100 ORDER BY "id" LIMIT 1
# idx = 100, Tetradic uninflammable lionet phthiocol unhumble resatisfy tumultuation
# sr.rb:52: undefined method `output' for nil:NilClass (NoMethodError)
#   from /opt/local/lib/ruby/gems/1.8/gems/extlib-0.9.13/lib/extlib/lazy_array.rb:458:in `each'
#   from /opt/local/lib/ruby/gems/1.8/gems/extlib-0.9.13/lib/extlib/lazy_array.rb:458:in `each'
#   from sr.rb:50

