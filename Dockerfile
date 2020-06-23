FROM ruby:2.6.5-alpine AS middleman

RUN apk add --update --no-cache npm git build-base

COPY docs/Gemfile docs/Gemfile.lock /

RUN bundle install --jobs=4

COPY docs /docs
COPY public /public
COPY swagger /swagger

WORKDIR docs
RUN bundle exec middleman build --build-dir=../public

###

FROM ruby:2.6.5-alpine

RUN apk add --update --no-cache tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN apk add --update --no-cache --virtual runtime-dependances \
 postgresql-dev git ncurses

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock

RUN apk add --update --no-cache --virtual build-dependances \
 build-base && \
 bundle install --jobs=4 && \
 apk del build-dependances

ADD . $APP_HOME/

COPY --from=middleman /public/ $APP_HOME/public/

CMD bundle exec rails db:create && bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
