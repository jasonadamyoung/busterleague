#!/bin/bash
# something is broken with gem wrappers
/usr/local/rvm/bin/rvm get head
/usr/local/rvm/bin/rvm @global do gem update --system
/usr/local/rvm/bin/rvm @global do gem update bundler --force
/usr/local/rvm/bin/rvm alias create default 2.7.2@webapp --create
gem install pry