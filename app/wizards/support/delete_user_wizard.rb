# frozen_string_literal: true

module Support
  class DeleteUserWizard
    include DfE::Wizard

    attr_accessor :recruitment_cycle_year, :user_id

    def steps_processor
      DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
        graph.root :confirm

        graph.add_node :confirm, Steps::Confirm
        graph.add_node :users_index, DfE::Wizard::Core::Redirect

        graph.add_edge from: :confirm, to: :users_index
      end
    end

    def steps_operator
      DfE::Wizard::StepsOperator::Builder.draw(wizard: self, callable: state_store) do |builder|
        builder.on_step(:confirm, use: [Operations::DeleteUser])
      end
    end

    def route_strategy
      DfE::Wizard::RouteStrategy::DynamicRoutes.new(
        state_store:,
        path_builder: lambda { |step_id, _state_store, helpers, _options|
          case step_id
          when :users_index
            helpers.support_recruitment_cycle_users_path(recruitment_cycle_year)
          else
            helpers.delete_support_recruitment_cycle_user_path(recruitment_cycle_year, user_id)
          end
        },
      )
    end

    def final_step?
      current_step_name == :confirm
    end

    def user
      @user ||= User.find(user_id)
    end

    def extract_step_params_from_request
      return {} if @current_step_params[current_step_name].blank? && @current_step_params[current_step_name.to_s].blank?

      super
    end
  end
end
