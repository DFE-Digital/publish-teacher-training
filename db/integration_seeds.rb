require_relative "../spec/strategies/find_or_create_strategy"
Faker::Config.locale = "en-GB"

current_recruitment_cycle = RecruitmentCycle.current_recruitment_cycle

provider_codes = ("0AA".."0AZ").to_a

provider_codes.each do |provider_code|
  provider = Provider.find_by(provider_code: provider_code, recruitment_cycle: current_recruitment_cycle)
  if provider.blank?

    provider = FactoryBot.create(:provider, provider_code: provider_code, recruitment_cycle: current_recruitment_cycle)

    12.times do
      FactoryBot.create(:course, provider: provider)
    end

    puts "Created #{provider}"
  end
end
