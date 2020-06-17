ARG  DOCKER_REPOSITORY=dfedigital
ARG  TEACHER_TRAINING_API=teacher-training-api
ARG  CODE_VERSION=latest

FROM ${DOCKER_REPOSITORY}/${TEACHER_TRAINING_API}:${CODE_VERSION}

CMD date; nc -vz -w 10 $DB_HOSTNAME $DB_PORT; bundle exec rails db:migrate && bundle exec sidekiq -q mailer
