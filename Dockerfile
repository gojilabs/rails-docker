ARG RUBY_VERSION=latest
FROM gojilabs/ruby:${RUBY_VERSION}
LABEL maintainer="Adam Sumner <adamsumner@gmail.com>"

# Setup default environment variables
ARG APP_DIR=/var/app
ARG AUTHENTICATION_SALT=bogus
ARG PORT=3000
ARG PROJECT_ENV=production
ARG REDIS_URL=redis://localhost:6379/1
ARG SECRET_KEY_BASE=bogus
ARG SECRET_SALT=bogus
ARG UUID_NAMESPACE=bogus

# Setup dependent environment variables
ARG APP_ENV=${PROJECT_ENV}
ARG GOJI_ENV=${PROJECT_ENV}
ARG NODE_ENV=${PROJECT_ENV}
ARG RACK_ENV=${PROJECT_ENV}
ARG RAILS_ENV=${PROJECT_ENV}

# Setup static environment variables
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# Install bundled gems
RUN mkdir -p ${APP_DIR}
COPY Gemfile Gemfile.lock ${APP_DIR}
RUN cd ${APP_DIR} && bundle install --without=development test --jobs=5 --retry=5 --deployment

# Copy entire project
COPY . ${APP_DIR}
RUN cd ${APP_DIR} && rm -rf node_modules storage/* log/* tmp/cache/* tmp/pids/* tmp/sockets/*

# Precompile assets
RUN cd ${APP_DIR} && bin/rails assets:clobber && bin/rails assets:precompile

# Set working directory
WORKDIR ${APP_DIR}

# Export container port
EXPOSE ${PORT}

# Run startup commands
CMD ["sh", "${APP_DIR}/run.sh"]
