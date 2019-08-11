ARG BUSTERRAILS_IMAGE_SOURCE
FROM $BUSTERRAILS_IMAGE_SOURCE
# extra nginx configuration
ADD ./build/staticfiles.conf /etc/nginx/sites-extra.d/staticfiles.conf
# application
COPY --chown=app:app . $APP_HOME
# check bundle on startup
COPY ./build/localdev.bundlecheck.sh /etc/my_init.d
# development version
ENV PASSENGER_APP_ENV=development 


