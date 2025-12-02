# lib/rubocop/cop/your_namespace/no_feature_flag_activate_in_specs.rb
require "rubocop"

module RuboCop
  module Cop
    module RSpec
      # Warns against using `FeatureFlag.activate` in specs.
      #
      # @example
      #   # bad
      #   FeatureFlag.activate(:some_flag)
      #
      #   # good
      #   # allow(FeatureFlag).to receive(:some_flag).and_return(true)
      #
      class NoFeatureFlagActivate < Base
        extend AutoCorrector

        MSG = "Avoid using `FeatureFlag.activate` in specs. " \
              "Use `allow(FeatureFlag).to receive(:flag).and_return(true)` instead.".freeze

        RESTRICT_ON_SEND = [:activate].freeze

        # @!method feature_flag_activate?(node)
        def_node_matcher :feature_flag_activate?, <<~PATTERN
          (send (const nil? :FeatureFlag) :activate (sym $_flag_name))
        PATTERN

        def on_send(node)
          flag_name = feature_flag_activate?(node)
          return unless flag_name

          add_offense(node) do |corrector|
            replacement = "allow(FeatureFlag).to receive(:active?).with(:#{flag_name}).and_return(true)"
            corrector.replace(node, replacement)
          end
        end
      end
    end
  end
end
