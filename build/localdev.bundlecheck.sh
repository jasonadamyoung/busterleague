#!/bin/bash
cd $APP_HOME
bundle check || bundle install --jobs=4
