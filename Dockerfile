FROM ruby:2.5.3-alpine

RUN apk add --update tzdata && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

RUN apk add --update --virtual runtime-dependances \
 postgresql-dev

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock


RUN apk add --update --virtual build-dependances \
 build-base  && \
 bundle install --jobs=4 && \
 apk del build-dependances

ADD . $APP_HOME/

CMD bundle exec rails server -b 0.0.0.0
