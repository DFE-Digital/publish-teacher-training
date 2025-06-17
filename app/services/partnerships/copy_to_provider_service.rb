# frozen_string_literal: true

module Partnerships
  class CopyToProviderService
    def initialize
      @partnerships_count = 0
    end

    def execute(provider:, rolled_over_provider:, new_recruitment_cycle:)
      @provider = provider
      @rolled_over_provider = rolled_over_provider
      @new_recruitment_cycle = new_recruitment_cycle

      process_partnerships
      @partnerships_count
    end

  private

    def process_partnerships
      partnerships.each do |partnership|
        new_accredited = find_provider_in_cycle(partnership.accredited_provider.provider_code)
        new_training = find_provider_in_cycle(partnership.training_provider.provider_code)

        next unless valid_partnership?(new_accredited, new_training)

        create_partnership(new_accredited, new_training)
        @partnerships_count += 1
      end
    end

    def partnerships
      @partnerships ||= ProviderPartnership
        .where("accredited_provider_id = :id OR training_provider_id = :id", id: @provider.id)
        .includes(:accredited_provider, :training_provider)
    end

    def find_provider_in_cycle(provider_code)
      @new_recruitment_cycle.providers.find_by(provider_code: provider_code)
    end

    def valid_partnership?(accredited, training)
      accredited && training && partnership_involves_rolled_over?(accredited, training)
    end

    def partnership_involves_rolled_over?(accredited, training)
      accredited == @rolled_over_provider || training == @rolled_over_provider
    end

    def create_partnership(accredited_provider, training_provider)
      ProviderPartnership.find_or_create_by(
        accredited_provider:,
        training_provider:,
      )
    end
  end
end
