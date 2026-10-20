# frozen_string_literal: true

require "csv"

namespace :big_query do
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

      c.find_each(batch_size: 200, &:send_import_event)
    end
  end
end
