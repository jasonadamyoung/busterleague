#!/bin/bash
cd $APP_HOME
export HOME=$APP_HOME
bundle check || bundle install --jobs=4
