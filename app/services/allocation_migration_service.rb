require "csv"

class AllocationMigrationService
  def execute
    Allocation.all.each do |allocation|
      accredited_body = allocation.accredited_body
      provider = allocation.provider

      allocation.accredited_body_code = accredited_body.provider_code
      allocation.provider_code = provider.provider_code

      previous_accredited_body = previous_recruitment_cycle.providers.find_by!(provider_code: accredited_body.provider_code)

      if previous_accredited_body.accrediting_provider == "not_an_accredited_body"
        previous_accredited_body.update(accrediting_provider: "accredited_body")
      end

      previous_provider = previous_recruitment_cycle.providers.find_by(provider_code: provider.provider_code)

      if previous_provider.blank?
        puts "no previous provider: #{provider.provider_code}"

        missing_provider = provider.dup
        missing_provider.recruitment_cycle = previous_recruitment_cycle
        missing_provider.save!

        previous_provider = previous_recruitment_cycle.providers.find_by(provider_code: provider.provider_code)
      end

      allocation.accredited_body_id = previous_accredited_body.id
      allocation.provider_id = previous_provider.id

      allocation.recruitment_cycle_id = previous_recruitment_cycle.id

      puts "migrating allocation: #{allocation.id}. accredited body: #{accredited_body.provider_code}"
      allocation.save!
    end
  end

private

  def previous_recruitment_cycle
    @previous_recruitment_cycle ||= RecruitmentCycle.current.previous
  end
end
