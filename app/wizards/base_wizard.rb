# frozen_string_literal: true

# A wizard with one form step, a check answers page, and a commit.
#
# Answers are kept in Rails.cache under a key built from the wizard class,
# the context values and a per-journey state_key.
#
#   class Support::AddUserWizard < BaseWizard
#     form_step :details, Steps::Details
#     commit_with Operations::CreateUser
#
#     def build_step_path(helpers, step_id, **options)
#       helpers.wizard_support_recruitment_cycle_users_path(
#         context[:recruitment_cycle_year], state_key:, step: step_id, **options
#       )
#     end
#
#     def build_exit_path(helpers)
#       helpers.support_recruitment_cycle_users_path(context[:recruitment_cycle_year])
#     end
#   end
class BaseWizard
  include DfE::Wizard

  CACHE_EXPIRY = 24.hours

  class_attribute :form_step_id, :form_step_class, :commit_operation

  class << self
    def form_step(step_id, step_class)
      self.form_step_id = step_id
      self.form_step_class = step_class
    end

    def commit_with(operation)
      self.commit_operation = operation
    end

    # A new journey, positioned on the form step.
    def start(context:)
      new(state_key: SecureRandom.uuid, context:, current_step: form_step_id)
    end

    def repository_for(state_key:, context:)
      DfE::Wizard::Repository::Cache.new(
        cache: Rails.cache,
        key: [name.underscore.tr("/", "_"), *context.values, state_key].join("_"),
        expires_in: CACHE_EXPIRY,
      )
    end
  end

  attr_reader :state_key, :context

  def initialize(state_key:, context: {}, **)
    super(state_store: StateStore.new(repository: self.class.repository_for(state_key:, context:)), **)
    @state_key = state_key
    @context = context
  end

  def steps_processor
    DfE::Wizard::StepsProcessor::Graph.draw(self, predicate_caller: state_store) do |graph|
      graph.root form_step_id

      graph.add_node form_step_id, form_step_class
      graph.add_node :check_answers, CheckAnswers
      graph.add_node :exit, DfE::Wizard::Core::Redirect

      graph.add_edge from: form_step_id, to: :check_answers
      graph.add_edge from: :check_answers, to: :exit

      graph.before_previous_step(:handle_back_to_review)
    end
  end

  def steps_operator
    DfE::Wizard::StepsOperator::Builder.draw(wizard: self, callable: state_store) do |builder|
      builder.on_step(:check_answers, use: [commit_operation])
    end
  end

  def route_strategy
    DfE::Wizard::RouteStrategy::DynamicRoutes.new(
      state_store:,
      path_builder: lambda { |step_id, _state_store, helpers, options|
        step_id == :exit ? build_exit_path(helpers) : build_step_path(helpers, step_id, **options.compact)
      },
    )
  end

  # Subclasses return the path for a wizard step.
  def build_step_path(_helpers, _step_id, **_options)
    raise NotImplementedError, "#{self.class} must implement #build_step_path"
  end

  # Subclasses return where to go when the journey ends or is cancelled.
  def build_exit_path(_helpers)
    raise NotImplementedError, "#{self.class} must implement #build_exit_path"
  end

  def exit_path
    resolve_step_path(:exit)
  end

  def change_path
    resolve_step_path(form_step_id, return_to_review: form_step_id)
  end

  def final_step?
    current_step_name == :check_answers
  end

  # With one form step, the forward route always reaches check answers.
  # Only the back link changes: after a Change link, it returns to check answers.
  def handle_back_to_review
    return if return_to_review_param.blank?

    handle_back_in_check_your_answers(:check_answers, return_to_review_param)
  end

  # Change links put return_to_review on the query string. The wizard's filtered
  # step params do not include it, so this reads the raw request params.
  def return_to_review_param
    @current_step_params&.[](:return_to_review) || @current_step_params&.[]("return_to_review")
  end

  # The check answers form posts no step params.
  def extract_step_params_from_request
    return {} if @current_step_params[current_step_name].blank? && @current_step_params[current_step_name.to_s].blank?

    super
  end
end
