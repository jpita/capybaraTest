# frozen_string_literal: true

# The suite sets the app up and tears it down itself, so `bundle exec rspec` is
# all that is needed to run it. These tasks wrap that plus the app's own build,
# so a fresh clone has one entry point.

APP_DIR = File.expand_path('app', __dir__)
APP_CONTROL = File.expand_path('bin/app', __dir__)

namespace :app do
  desc 'Install and build the vendored app (the postinstall step builds it)'
  task :setup do
    sh "cd #{APP_DIR} && npm install --legacy-peer-deps"
  end

  desc 'Start the app'
  task :start do
    sh APP_CONTROL, 'start'
  end

  desc 'Stop the app'
  task :stop do
    sh APP_CONTROL, 'stop'
  end

  desc 'Restart the app, which wipes and reseeds its database'
  task :reset do
    sh APP_CONTROL, 'restart'
  end
end

desc 'Run the suite'
task :spec do
  sh 'bundle exec rspec'
end

desc 'Run the suite across several processes against one app instance'
task 'spec:parallel' do
  processes = (ENV['PROCESSES'] || 4).to_i

  # Tells spec_helper that this task owns the app, so no process resets it mid-run.
  ENV['SUITE_MANAGES_APP'] = '1'

  # parallel_tests writes per-file runtimes to the path given by --runtime-log, and
  # balances by them when asked to group by "runtime". It raises if that file does
  # not exist yet, and the documented "default" fallback is not accepted by the rspec
  # runner, so the first run groups by size and later runs balance by time.
  runtime_log = 'tmp/parallel_runtime_rspec.log'
  group_by = File.exist?(runtime_log) ? 'runtime' : 'filesize'

  sh "#{APP_CONTROL} restart"
  passed = system("bundle exec parallel_rspec --group-by #{group_by} --runtime-log #{runtime_log} -n #{processes} spec/features")
  sh "#{APP_CONTROL} restart"

  abort 'the parallel run failed' unless passed
end

task default: :spec
