# frozen_string_literal: true

task brakeman: :environment do
  sh <<~EOSHELL
    mkdir -p tmp && \
    (brakeman --no-progress -5 --quiet --color --output tmp/brakeman.out --exit-on-warn && \
    echo "No warnings or errors") || \
    (cat tmp/brakeman.out; exit 1)
  EOSHELL
end

task(:default).prerequisites << task(brakeman: :environment) if %w[development test].include? Rails.env
