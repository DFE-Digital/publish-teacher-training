# frozen_string_literal: true

require_relative '../../spec/strategies/find_or_create_strategy'
Faker::Config.locale = 'en-GB'

namespace :undergraduate do
  desc 'Create TDA courses'
  task create: :environment do
    providers_count = ENV.fetch('PROVIDERS_COUNT', 100)

    ActiveRecord::Base.transaction do
      recruitment_cycle = RecruitmentCycle.find_by!(year: '2025')
      recruitment_cycle.providers.limit(providers_count).each do |provider|
        is_send = [true, false].sample
        name = if is_send
                 'Mathematics (SEND)'
               else
                 'Mathematics'
               end

        FactoryBot.find_or_create(
          :course,
          :published_teacher_degree_apprenticeship,
          :secondary,
          :with_a_level_requirements,
          :with_gcse_equivalency,
          provider:,
          name:,
          subjects: [Subject.find_by!(subject_name: 'Mathematics')],
          applications_open_from: 2.days.ago,
          site_statuses: [FactoryBot.build(:site_status, :findable, site: FactoryBot.build(:site, provider:))]
        )
      end
    end
  end
end
