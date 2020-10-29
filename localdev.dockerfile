FROM phusion/passenger-ruby26
LABEL maintainer="jay@outfielding.net"

# update OS
COPY build/localdev.aptproxy /etc/apt/apt.conf.d/00proxy
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
# make sure there's tz data
RUN apt-get update && apt-get install -y sudo tzdata libmagickwand-dev imagemagick dnsutils iputils-ping

# node setup
RUN curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
RUN apt-get update && apt-get install -y nodejs

# db-to-sqlite setup
RUN apt-get update && apt-get install python3-pip -y
RUN pip3 install db-to-sqlite[postgresql]

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
ADD build/run_sidekiq_localdev.sh /etc/service/sidekiq/run

# workdir env
ENV APP_HOME /home/app/webapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# -=-=-=- BEGIN APP SPECIFIC CONFIG -=-=-=-

# extra nginx configuration
ADD ./build/staticfiles.conf /etc/nginx/sites-extra.d/staticfiles.conf
# application
COPY --chown=app:app . $APP_HOME
# check bundle on startup
COPY ./build/localdev.bundlecheck.sh /etc/my_init.d
# development version
ENV PASSENGER_APP_ENV=development
