# frozen_string_literal: true

# Drives bin/app from the suite. A run must start from the app's seeded data, and
# the app wipes and reseeds its database on every start, so restarting it is the
# reset. Failing here is better than running against an app in an unknown state.
module AppControl
  CONTROL = File.expand_path('../../bin/app', __dir__)

  def self.restart
    output = IO.popen([CONTROL, 'restart'], err: %i[child out], &:read)
    return if $?.success?

    raise "bin/app restart failed, so the suite cannot run.\n\n#{output}"
  end
end
