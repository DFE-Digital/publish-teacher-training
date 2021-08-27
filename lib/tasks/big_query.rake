require "csv"

namespace :big_query do
  desc <<~DESC
    Send import events for configured entities
  DESC

  task send_import_events: :environment do
    class CourseSite < ApplicationRecord; end

    class OrganisationProvider < ApplicationRecord; end

    class Session < ApplicationRecord; end

    conf = Rails.configuration.analytics

    classes = conf.keys.map { |k| k.to_s.camelize.constantize }

    classes.each do |c|
      puts "Queueing: #{c.count} #{c} entities"

      c.find_each(batch_size: 200, &:send_import_event)
    end
  end
end
