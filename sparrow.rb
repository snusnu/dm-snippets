
  module Sparrow

    def self.config
      Saleshub::Sparrow.config['m_queue'].merge(
        :host => Saleshub::Sparrow.config['host'],
        :port => Saleshub::Sparrow.config['port']
      )
    end


    def self.base
      File.expand_path(config['base'], Saleshub.root)
    end

    def self.pids
      File.expand_path(config['pids' ], Saleshub.root)
    end

    def self.pid_file_name
      File.expand_path("sparrow.#{config['port']}.pid", pids)
    end

    def self.log
      File.expand_path(config['log' ], Saleshub.root)
    end


    def self.pid
      File.new(pid_file_name, 'r').gets.to_i
    rescue Errno::ENOENT
      nil
    end

    def self.running?
      pid ? !!Process.getpgid(pid) : false
    rescue Errno::ESRCH # no such process
      File.delete(pid_file_name)
    rescue Errno::ENOENT # no such pid file
      puts "This shouldn't happen, go fix bugs!"
    end

    def self.start
      if running?
        puts "Sparrow is already running at #{pid}"
        return
      else
        start_sparrow = "sparrow --host #{config['host']} --port #{config['port']} --base #{base} --pid #{pids} --log #{log} --daemon"
        puts "Starting sparrow with:\n#{start_sparrow}"
        system start_sparrow
      end
    end

    def self.stop
      if running?
        stop_sparrow = "sparrow --base #{base} --pid #{pids} --kill-all"
        puts "Stopping sparrow with:\n#{stop_sparrow}"
        system stop_sparrow
      else
        puts "Sparrow isn't running #{pid ? 'at ' + pid : ''}"
      end
    end


    module Client

      def self.config
        Saleshub::Sparrow.config['m_queue']
      end

      def self.start
        Saleshub.load_environment
        MQueue::Daemon.daemonize!("quote_worker") do
          Dir.chdir Merb.root
          run
        end
      end

      def self.stop
        ::MQueue::Daemon.kill!("quote_worker")
      end

      def self.restart
        stop
        start
      end

      def self.ontop
        Saleshub.load_environment
        run
      end


      private

      def self.run
        puts "entered run"
        Saleshub::Sparrow.start unless Saleshub::Sparrow.running?
        Process.setpriority(Process::PRIO_PROCESS, 0, 19)
        require 'lib/workers/quote_queue'
        QuoteQueue.servers = m_queue_servers
        QuoteQueue.publish('quote_queue')
        QuoteQueue.run
        puts "finished run"
      end

      def self.m_queue_servers
        [ ::MQueue::Protocols::Sparrow.new(config) ]
      end

    end

  end
end

