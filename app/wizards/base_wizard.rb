# frozen_string_literal: true

# A wizard with one or more form steps in a fixed order, a check answers
# page, and a commit. For branching journeys, use DfE::Wizard directly.
# See guides/base-wizard.md.
#
# Answers are kept in Rails.cache under a key built from the wizard class,
# the context values and a per-journey state_key. Attribute names must be
# unique across steps, because the gem stores all answers in one hash.
#
#   class Support::AddUserWizard < BaseWizard
#     step :details, Steps::Details
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

  class_attribute :form_steps, default: {}
  class_attribute :commit_operation

  class << self
    def step(step_id, step_class)
      self.form_steps = form_steps.merge(step_id => step_class)
    end

    def first_step_id
      form_steps.keys.first
    end

    def commit_with(operation)
      self.commit_operation = operation
    end

    # A new journey, positioned on the first step.
    def start(context:)
      new(state_key: SecureRandom.uuid, context:, current_step: first_step_id)
    end

    def repository_for(state_key:, context:)
      DfE::Wizard::Repository::Cache.new(
        cache: Rails.cache,
        # Sorted by key, so the order the context is built in does not matter.
        key: [name.underscore.tr("/", "_"), *context.sort_by { |key, _| key.to_s }.map(&:last), state_key].join("_"),
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
      graph.root self.class.first_step_id

      form_steps.each { |step_id, step_class| graph.add_node step_id, step_class }
      graph.add_node :check_answers, CheckAnswers
      graph.add_node :exit, DfE::Wizard::Core::Redirect

      [*form_steps.keys, :check_answers, :exit].each_cons(2) do |from, to|
        graph.add_edge from:, to:
      end

      graph.before_next_step(:handle_return_to_review)
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

  def change_path(step_id = self.class.first_step_id)
    resolve_step_path(step_id, return_to_review: step_id)
  end

  def final_step?
    current_step_name == :check_answers
  end

  # After a Change link, Continue returns to check answers instead of the
  # next step, once every step before check answers is saved.
  def handle_return_to_review
    return if return_to_review_param.blank?

    handle_return_to_check_your_answers(:check_answers)
  end

  # After a Change link, Back returns to check answers, once every step
  # before check answers is valid. Otherwise Back goes to the previous step.
  def handle_back_to_review
    return if return_to_review_param.blank?
    return unless valid_path_to?(:check_answers)

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
