#!/bin/bash
# uninstall all versions of bundler
/usr/local/rvm/bin/rvm @global do gem update --system
/usr/local/rvm/bin/rvm @global do gem update bundler --force
/usr/local/rvm/bin/rvm alias create default 2.6.3@webapp --create
gem install pry