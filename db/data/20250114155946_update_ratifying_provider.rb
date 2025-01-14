# frozen_string_literal: true

class UpdateRatifyingProvider < ActiveRecord::Migration[8.0]
  PROVIDERS = %w[5W1 1BJ 24H 4R4 3A7].freeze
  TARGET_PROVIDER = '3A1'

  def up
    PROVIDERS.each do |training_provider_code|
      UpdateRatifyingProviderForCourse.new(training_provider_code:, target_ratifying_provider_code: TARGET_PROVIDER).call
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
