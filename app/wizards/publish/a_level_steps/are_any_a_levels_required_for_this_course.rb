# frozen_string_literal: true

module Publish
  module ALevelSteps
    class AreAnyALevelsRequiredForThisCourse < DfE::Wizard::Step
      # attr_accessor :answer
      # validates :answer, presence: true

      # def self.permitted_params
      #   [:answer]
      # end

      # def previous_step
      #   :first_step
      # end

      def next_step
        :what_alevel_is_required
      #   if answer == 'yes'
      #     :third_step
      #   elsif answer == 'no'
      #     :second_step
      #   end
      end

      delegate :provider_code, :recruitment_cycle_year, :code, to: :wizard
      def next_step_path_arguments
        { provider_code:, recruitment_cycle_year:, code: }
      end
    end
  end
end
