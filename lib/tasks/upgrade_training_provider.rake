# frozen_string_literal: true

desc "Promote training providers to accredited providers"
task :promote_training_providers, %i[year code number] => :environment do |_t, args|
  Rails.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

  year = args[:year]
  code = args[:code]
  number = args[:number]

  training_provider = RecruitmentCycle.find_by!(year:).providers.find_by!(provider_code: code)

  Providers::PromoteTrainingProviderAccreditation.new(training_provider, number).call
end
