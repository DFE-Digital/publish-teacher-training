ARG  DOCKER_REPOSITORY
ARG  TEACHER_TRAINING_API
ARG  CODE_VERSION=${GIT_BRANCH:-latest}

FROM ${DOCKER_REPOSITORY}/${TEACHER_TRAINING_API}:${CODE_VERSION}

CMD bundle exec rails db:migrate && bundle exec sidekiq -q save_statistic
