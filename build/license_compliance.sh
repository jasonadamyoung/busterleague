# additional packages for license_compliance
apt-get update
apt-get install -y sudo tzdata libmagickwand-dev imagemagick dnsutils iputils-ping postgresql-client
apt-get install -y --no-install-recommends build-essential zlib1g-dev libssl-dev
# weird
bundle config --local path vendor
bundle config --local jobs "$(nproc)"
bundle install
yarn install
