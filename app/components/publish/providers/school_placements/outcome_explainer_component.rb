# frozen_string_literal: true

module Publish
  module Providers
    module SchoolPlacements
      class OutcomeExplainerComponent < ApplicationComponent
        def initialize(recruitment_cycle:, provider:, **kwargs)
          @recruitment_cycle = recruitment_cycle
          @provider = provider

          super(**kwargs)
        end
      end
    end
  end
end
