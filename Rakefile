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

task default: :spec
