#!/bin/sh
echo "Running init task: bundle exec rake db:migrate "
bundle exec rake db:migrate
