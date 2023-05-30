FROM ruby:2.7.5-alpine3.15 AS middleman

RUN apk add --update --no-cache npm git build-base

COPY docs/Gemfile docs/Gemfile.lock /

RUN bundle install --jobs=4

COPY docs /docs
COPY public /public
COPY swagger /swagger

WORKDIR docs
RUN bundle exec middleman build --build-dir=../public

###

FROM ruby:3.1-alpine3.15

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN apk add --update --no-cache --virtual runtime-dependances \
 postgresql-dev git ncurses shared-mime-info

# Remove once the base image ruby:3.1-alpine3.15 has been updated with the below pkgs
RUN apk add --no-cache ncurses=6.3_p20211120-r2 ncurses-libs=6.3_p20211120-r2

ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock

RUN apk add --update --no-cache --virtual build-dependances \
 build-base && \
 apk add --update --no-cache libpq yarn && \
 bundle install --jobs=4 && \
 rm -rf /usr/local/bundle/cache && \
 apk del build-dependances

COPY package.json yarn.lock ./
RUN  yarn install --frozen-lockfile && \
     yarn cache clean

ADD . $APP_HOME/

COPY --from=middleman /public/ $APP_HOME/public/docs/

RUN ls /app/public/ && \
    yarn build && \
    bundle exec rake assets:precompile && \
    rm -rf node_modules tmp

ARG COMMIT_SHA
ENV COMMIT_SHA=${COMMIT_SHA}

CMD bundle exec rails db:migrate:with_data_migrations && bundle exec rails server -b 0.0.0.0
