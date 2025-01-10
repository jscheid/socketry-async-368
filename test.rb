require 'statsd'
require 'async'
require 'pry-remote'

# For debugging
Thread.new { loop { binding.remote_pry('0.0.0.0') } }

# Read command line arg
async_percent = (ARGV[0] || '0.5').to_f
puts "Using async_percent: #{async_percent}"

# Set up statsd instance
$statsd = Statsd.new
$statsd.port = 45_678 # any port without listener (on 127.0.0.1)

# Collect tasks here
$tasks = []

def report_timings
  100.times { $statsd.timing('glork', 320) }
end

threads =
  (1..10).map do |i|
    Thread.new do
      if rand < async_percent
        puts "Start #{i} (async)"
        Sync { $tasks << Async { report_timings } }
      else
        puts "Start #{i} (sync)"
        report_timings
      end
      puts "Done #{i}"
    end
  end

# Wait for all to finish
threads.each(&:join)
