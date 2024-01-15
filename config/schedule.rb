#if ENV['RAILS_ENV'] == "development"
  set :bundle_command, '/Users/edjefferson/.asdf/shims/bundler exec'
  set :job_template, "/bin/zsh -l -c ':job'"
  set :environment, "development"
#end
#env :PATH, ENV['PATH']

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever



#end

