FROM ruby:2.5.3-alpine

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk add --update build-base postgresql-dev tzdata

ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install

ADD . $APP_HOME/

CMD bundle exec rails server -b 0.0.0.0
