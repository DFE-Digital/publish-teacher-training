require "factory_bot"

module FactoryBot
  module Strategy
    class Find
      def association(runner)
        runner.run
      end

      def result(evaluation)
        build_class(evaluation).where(get_match_attributes(evaluation)).first
      end

    private

      def build_class(evaluation)
        @build_class ||= evaluation
                           .instance_variable_get(:@attribute_assigner)
                           .instance_variable_get(:@build_class)
      end

      def get_match_attributes(evaluation)
        evaluation.hash.keep_if do |attr, _value|
          attr.to_s.in? build_class(evaluation).column_names
        end
      end

      def get_overrides(evaluation = nil)
        evaluation.object
        return @overrides unless @overrides.nil?

        evaluation.instance_variable_get(:@attribute_assigner)
          .instance_variable_get(:@evaluator)
          .instance_variable_get(:@overrides)
          .clone
      end
    end

    class FindOrCreate
      def initialize
        @strategy = FactoryBot.strategy_by_name(:find).new
      end

      delegate :association, to: :@strategy

      def result(evaluation)
        found_object = @strategy.result(evaluation)

        if found_object.nil?
          @strategy = FactoryBot.strategy_by_name(:create).new
          @strategy.result(evaluation)
        else
          found_object
        end
      end
    end
  end
end

FactoryBot.register_strategy(:find, FactoryBot::Strategy::Find)
FactoryBot.register_strategy(:find_or_create, FactoryBot::Strategy::FindOrCreate)
