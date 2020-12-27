#!/bin/bash
# uninstall all versions of bundler
gem install gem-wrappers
/usr/local/rvm/bin/rvm @global do gem update --system
/usr/local/rvm/bin/rvm @global do gem update bundler --force
/usr/local/rvm/bin/rvm @global do gem install gem-wrappers
/usr/local/rvm/bin/rvm alias create default 2.6.6@webapp --create
gem install pry