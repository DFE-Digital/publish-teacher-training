# frozen_string_literal: true

# Controller actions for a BaseWizard.
#
# Including controllers define:
#   wizard_class           - the BaseWizard subclass
#   wizard_context         - a hash of route params that scope the journey
#   wizard_success_message - the flash shown after the commit
#
# They can override wizard_completed_path, which defaults to the exit path.
#
# Step partials live in "<controller_path>/steps/_<step_id>.html.erb".
module BaseWizardController
  extend ActiveSupport::Concern

  included do
    before_action :set_wizard, except: :new

    helper_method :wizard, :current_step, :current_step_name
  end

  def new
    redirect_to wizard_class.start(context: wizard_context).current_step_path
  end

  def show
    render "base_wizards/show"
  end

  def update
    if wizard.save_current_step
      return complete if wizard.final_step?

      redirect_to wizard.next_step_path
    else
      render "base_wizards/show", status: :unprocessable_content
    end
  end

private

  attr_reader :wizard

  delegate :current_step, :current_step_name, to: :wizard

  def complete
    wizard.clear_state
    flash[:success] = wizard_success_message
    redirect_to wizard_completed_path
  end

  def wizard_completed_path
    wizard.exit_path
  end

  # A step with no page, such as a mistyped step or :exit, is not found.
  def set_wizard
    step_id = wizard_class.page_step_id(params[:step])
    return render_not_found if step_id.nil?

    @wizard = wizard_class.new(
      state_key: params[:state_key],
      context: wizard_context,
      current_step: step_id,
      current_step_params: params,
    )
  end
end
