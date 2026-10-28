# frozen_string_literal: true

module Support
  class AddUserWizard
    include DfE::Wizard

    attr_accessor :recruitment_cycle_year, :state_key

    def steps_processor
      DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
        graph.root :details

        graph.add_node :details, Steps::Details
        graph.add_node :check_answers, Steps::CheckAnswers
        graph.add_node :users_index, DfE::Wizard::Core::Redirect

        graph.add_edge from: :details, to: :check_answers
        graph.add_edge from: :check_answers, to: :users_index

        graph.before_next_step(:handle_return_to_review)
        graph.before_previous_step(:handle_back_to_review)
      end
    end

    def handle_return_to_review
      return if return_to_review_param.blank?

      handle_return_to_check_your_answers(:check_answers)
    end

    def handle_back_to_review
      return if return_to_review_param.blank?

      handle_back_in_check_your_answers(:check_answers, return_to_review_param)
    end

    def steps_operator
      DfE::Wizard::StepsOperator::Builder.draw(wizard: self, callable: state_store) do |builder|
        builder.on_step(:check_answers, use: [DfE::Wizard::Operations::Validate, Operations::CreateUser])
      end
    end

    def route_strategy
      DfE::Wizard::RouteStrategy::DynamicRoutes.new(
        state_store:,
        path_builder: lambda { |step_id, _state_store, helpers, options|
          case step_id
          when :users_index
            helpers.support_recruitment_cycle_users_path(recruitment_cycle_year)
          else
            helpers.wizard_support_recruitment_cycle_users_path(
              recruitment_cycle_year,
              state_key:,
              step: step_id,
              **options,
            )
          end
        },
      )
    end

    def final_step?
      current_step_name == :check_answers
    end

    # Change links put return_to_review on the query string. The wizard's filtered
    # step params do not include it, so this reads the raw request params.
    def return_to_review_param
      @current_step_params&.[](:return_to_review) || @current_step_params&.[]("return_to_review")
    end

    def extract_step_params_from_request
      return {} if step_params_missing?

      super
    end

  private

    def step_params_missing?
      @current_step_params[current_step_name].blank? && @current_step_params[current_step_name.to_s].blank?
    end
  end
end
