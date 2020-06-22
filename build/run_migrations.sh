#!/bin/sh
echo "Running init task: bundle exec rake db:migrate "
cd $APP_HOME
export HOME=$APP_HOME
bundle exec rake db:migrate
