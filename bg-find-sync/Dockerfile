ARG  DOCKER_REPOSITORY
ARG  MANAGE_COURSES_BACKEND_IMAGE
ARG  CODE_VERSION=latest

FROM ${DOCKER_REPOSITORY}/${MANAGE_COURSES_BACKEND_IMAGE}:${CODE_VERSION}

CMD bundle exec rails db:migrate && bundle exec bin/delayed_job --queue=find_sync run
