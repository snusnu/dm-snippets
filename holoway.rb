require 'rubygems'
require 'dm-core'
require 'spec'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, 'sqlite3::memory:')

class Job
  include DataMapper::Resource
  property :id, Serial
  has n, :agents, :through => Resource
end

class Agent
  include DataMapper::Resource
  property :id, Serial
  has n, :jobs, :through => Resource
end

describe "Anonymous m:m relationships" do
  before :each do
    DataMapper.auto_migrate!
    @job = Job.create :agents => [ Agent.new ]
    @agent = @job.agents.first
  end
  it "should establish the relationships in both directions" do
    @job.agents.should == [ @agent ]
    @agent.jobs.should == [ @job   ]
  end
  it "should allow to call #reload on the target collections" do
    lambda { @agent.jobs.reload }.should_not raise_error
  end
  it "should allow to call #destroy on an intermediate resource" do
    @job.agent_jobs.delete_at(0)
    @job.agent_jobs.save
    AgentJob.all.size.should == 0
  end
end

__END__

mungo:snippets snusnu$ spec -cfs holoway.rb 

Anonymous m:m relationships
 ~ (0.000132) SELECT sqlite_version(*)
 ~ (0.000104) DROP TABLE IF EXISTS "jobs"
 ~ (0.000016) DROP TABLE IF EXISTS "agents"
 ~ (0.000030) DROP TABLE IF EXISTS "agent_jobs"
 ~ (0.000025) PRAGMA table_info("jobs")
 ~ (0.000378) CREATE TABLE "jobs" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
 ~ (0.000010) PRAGMA table_info("agents")
 ~ (0.000114) CREATE TABLE "agents" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)
 ~ (0.000009) PRAGMA table_info("agent_jobs")
 ~ (0.000174) CREATE TABLE "agent_jobs" ("job_id" INTEGER NOT NULL, "agent_id" INTEGER NOT NULL, PRIMARY KEY("job_id", "agent_id"))
 ~ (0.000035) INSERT INTO "jobs" DEFAULT VALUES
 ~ (0.000034) INSERT INTO "agents" DEFAULT VALUES
 ~ (0.000049) SELECT "job_id", "agent_id" FROM "agent_jobs" WHERE "agent_id" = 1 AND "job_id" = 1 ORDER BY "job_id", "agent_id" LIMIT 1
 ~ (0.000051) INSERT INTO "agent_jobs" ("job_id", "agent_id") VALUES (1, 1)
 ~ (0.000069) SELECT "jobs"."id" FROM "jobs" INNER JOIN "agent_jobs" ON "jobs"."id" = "agent_jobs"."job_id" INNER JOIN "agents" ON "agent_jobs"."agent_id" = "agents"."id" WHERE "agent_jobs"."agent_id" = 1 GROUP BY "jobs"."id" ORDER BY "jobs"."id"
- should establish the relationships in both directions
 ~ (0.000037) INSERT INTO "jobs" DEFAULT VALUES
 ~ (0.000033) INSERT INTO "agents" DEFAULT VALUES
 ~ (0.000037) SELECT "job_id", "agent_id" FROM "agent_jobs" WHERE "agent_id" = 2 AND "job_id" = 2 ORDER BY "job_id", "agent_id" LIMIT 1
 ~ (0.000049) INSERT INTO "agent_jobs" ("job_id", "agent_id") VALUES (2, 2)
 ~ (0.000031) SELECT "job_id", "agent_id" FROM "agent_jobs" WHERE "job_id" = 2 ORDER BY "job_id", "agent_id" LIMIT 1
 ~ (0.000047) DELETE FROM "agent_jobs" WHERE "job_id" = 2 AND "agent_id" = 2
 ~ (0.000045) SELECT "job_id", "agent_id" FROM "agent_jobs" ORDER BY "job_id", "agent_id"
- should allow to call #destroy on an intermediate resource (FAILED - 1)

1)
'Anonymous m:m relationships should allow to call #destroy on an intermediate resource' FAILED
expected: 0,
     got: 1 (using ==)
./holoway.rb:37:

Finished in 0.023077 seconds

2 examples, 1 failure
