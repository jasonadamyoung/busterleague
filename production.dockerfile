ARG BUSTERRAILS_IMAGE_SOURCE
FROM $BUSTERRAILS_IMAGE_SOURCE
# extra nginx configuration
ADD ./build/staticfiles.conf /etc/nginx/sites-extra.d/staticfiles.conf
# application
COPY --chown=app:app . $APP_HOME
WORKDIR $APP_HOME
# set production for the docker build
ENV RAILS_ENV production
# bundle install
RUN bundle install --without development test
# assets
RUN sudo -u app RAILS_ENV=production bundle exec rake assets:precompile
