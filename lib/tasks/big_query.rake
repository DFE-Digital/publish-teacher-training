require "csv"

namespace :big_query do
  Object.const_set("ON_REDIS_ERROR_WAIT_TIME_IN_SECONDS", 10)
  Object.const_set("ON_REDIS_ERROR_RETRY_ATTEMPTS", 5)

  desc <<~DESC
    Send import events for configured entities
  DESC

  task send_import_events: :environment do |_task, args|
    Object.const_set("CourseSite", Class.new(ApplicationRecord))
    Object.const_set("OrganisationProvider", Class.new(ApplicationRecord))
    Object.const_set("Session", Class.new(ApplicationRecord))

    conf = Rails.configuration.analytics

    provided_models = *args
    classes = (provided_models.presence || conf.keys).map { |k| k.to_s.camelize.constantize }

    classes.each do |c|
      puts "Queueing: #{c.count} #{c} entities"

      c.find_each(batch_size: 200) do |entity|
        attempt_count = 0
        begin
          entity.send_import_event
        rescue Redis::CommandError
          attempt_count += 1
          abort if attempt_count > ON_REDIS_ERROR_RETRY_ATTEMPTS

          Rails.logger.info "sleeping for #{ON_REDIS_ERROR_WAIT_TIME_IN_SECONDS} - redis error"

          sleep ON_REDIS_ERROR_WAIT_TIME_IN_SECONDS
          retry
        end
      end
    end
  end
end
