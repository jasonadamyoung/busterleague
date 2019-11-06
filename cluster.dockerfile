FROM phusion/passenger-ruby26
LABEL maintainer="jay@outfielding.net"
# update OS
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
# make sure there's tz data
RUN apt-get update && apt-get install -y sudo tzdata libmagickwand-dev imagemagick
# apt cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# rvm configuration
COPY build/rvmrc /etc/rvmrc

# update rubygems and bundler
RUN mkdir /build
COPY build/gemset_setup.sh /build
RUN /build/gemset_setup.sh


# nginx configuration
RUN rm /etc/nginx/sites-enabled/default
ADD build/rails-env.conf /etc/nginx/main.d/rails-env.conf
ADD build/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mkdir /etc/nginx/sites-extra.d
RUN rm -f /etc/service/nginx/down

# sidekiq runit
RUN mkdir /etc/service/sidekiq
ADD build/run_sidekiq.sh /etc/service/sidekiq/run


# workdir env
ENV APP_HOME /home/app/webapp
RUN mkdir $APP_HOME

# -=-=-=- BEGIN APP SPECIFIC CONFIG -=-=-=-
ENV RAILS_ENV production
# extra nginx configuration
ADD ./build/staticfiles.conf /etc/nginx/sites-extra.d/staticfiles.conf
ADD ./build/ignorehealthcheck.conf /etc/nginx/sites-extra.d/ignorehealthcheck.conf
# bundle install
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install
# application
WORKDIR $APP_HOME
COPY --chown=app:app . $APP_HOME
# dmbweb symlink
RUN ln -s /dmbexport/dmbweb $APP_HOME/public/dmbweb
# version from gitlab
ARG VCS_REF=""
ENV SHA=${VCS_REF}
# assets
RUN sudo -u app RAILS_ENV=production bundle exec rake assets:precompile