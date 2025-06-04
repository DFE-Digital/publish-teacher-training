# frozen_string_literal: true

module Partnerships
  class CopyToProviderService
    def execute(provider:, rolled_over_provider:, new_recruitment_cycle:)
      partnerships_count = 0

      partnerships = ProviderPartnership.where(
        "accredited_provider_id = :id OR training_provider_id = :id",
        id: provider.id,
      )
      partnerships.find_each do |partnership|
        new_accredited = find_provider_in_cycle(
          partnership.accredited_provider.provider_code,
          new_recruitment_cycle,
        )
        new_training = find_provider_in_cycle(
          partnership.training_provider.provider_code,
          new_recruitment_cycle,
        )

        next unless new_accredited && new_training
        next unless partnership_involves_rolled_over?(new_accredited, new_training, rolled_over_provider)

        create_partnership(new_accredited, new_training)
        partnerships_count += 1
      end

      partnerships_count
    end

  private

    def find_provider_in_cycle(provider_code, cycle)
      cycle.providers.find_by(provider_code:)
    end

    def partnership_involves_rolled_over?(accredited, training, rolled_over)
      accredited == rolled_over || training == rolled_over
    end

    def create_partnership(accredited, training)
      ProviderPartnership.find_or_create_by(
        accredited_provider: accredited,
        training_provider: training,
      )
    end
  end
end
