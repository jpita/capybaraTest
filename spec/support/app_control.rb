# frozen_string_literal: true

require 'net/http'

# Drives bin/app from the suite. A run must start from the app's seeded data, and
# the app wipes and reseeds its database on every start, so restarting it is the
# reset. Failing here is better than running against an app in an unknown state.
#
# Under `rake spec:parallel` several processes run at once. A restart per process
# would land one process's database reset in the middle of another process's
# example, so there the launcher owns the app: it starts the app once before the
# run and resets it once after, and the processes only wait for it to answer.
module AppControl
  CONTROL = File.expand_path('../../bin/app', __dir__)
  MANAGED = ENV['SUITE_MANAGES_APP'] == '1'
  PORT = ENV.fetch('PORT', '3000')

  def self.prepare
    return wait_until_up if MANAGED

    restart
  end

  def self.finish
    return if MANAGED

    restart
  end

  def self.restart
    output = IO.popen([CONTROL, 'restart'], err: [:child, :out], &:read)
    return if $?.success?

    raise "bin/app restart failed, so the suite cannot run.\n\n#{output}"
  end

  # A process that is not the launcher only needs the app to be answering. The
  # launcher has already reset the database before starting these processes.
  def self.wait_until_up(seconds = 60)
    deadline = Time.now + seconds
    until app_answers?
      raise "the app did not answer on port #{PORT} within #{seconds}s" if Time.now > deadline

      sleep 0.2
    end
  end

  def self.app_answers?
    Net::HTTP.get_response(URI("http://localhost:#{PORT}/")).code == '200'
  rescue StandardError
    false
  end
end
