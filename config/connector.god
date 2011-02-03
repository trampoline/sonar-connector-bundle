# run with: god -c ./config/connector.god -l log/god.log --log-level=info

CONNECTOR_ROOT = File.expand_path("../..", __FILE__)
God.pid_file_directory = File.join(CONNECTOR_ROOT, 'var', 'pids')
FileUtils.mkdir_p( God.pid_file_directory )

God.watch do |w|
  w.name = "sonar-connector"
  w.interval = 30.seconds # default
  
  w.start = %Q{exec java -jar #{CONNECTOR_ROOT}/lib/jruby-complete.jar -e "require '#{CONNECTOR_ROOT}/lib/jruby_start'" > #{CONNECTOR_ROOT}/log/stdout_stderr.log 2>&1}
  # w.stop = "kill `cat #{File.join God.pid_file_directory, w.name + '.pid'}`"
  # w.restart = nil # restart is a call to stop followed by a call to start
  # w.pid_file = nil # no pid file cos we want god to daemonize this process for us
  
  w.start_grace = 10.seconds
  w.restart_grace = 20.seconds
  
  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 500.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
  
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
  
  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
