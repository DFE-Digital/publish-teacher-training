class EditInitialRequestFlow
  include Rails.application.routes.url_helpers

  attr_reader :params

  delegate :valid?, to: :form_object

  def initialize(params:)
    @params = params
  end

  def template
    if can_proceed_to_check_answers_page?
      "publish/providers/allocations/edit_initial_allocations/check_answers"
    elsif can_proceed_to_number_of_places_page?
      "publish/providers/allocations/edit_initial_allocations/number_of_places"
    else
      "publish/providers/allocations/edit_initial_allocations/do_you_want"
    end
  end

  def locals
    {
      training_provider:,
      provider:,
      form_object:,
      recruitment_cycle:,
      allocation:,
    }
  end

  def redirect_path
    if can_proceed_to_check_answers_page? || accepted_initial_allocation?
      publish_provider_recruitment_cycle_allocation_get_edit_initial_request_path(
        provider_code: allocation.accredited_body.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        allocation_training_provider_code: allocation.provider.provider_code,
        number_of_places: params[:number_of_places],
        next_step: params[:next_step],
        id: allocation.id,
        request_type: params[:request_type],
      )
    else
      publish_provider_recruitment_cycle_allocation_delete_initial_request_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        allocation_training_provider_code: training_provider.provider_code,
        id: allocation.id,
      )
    end
  end

private

  def accepted_initial_allocation?
    params[:next_step] == "number_of_places" && params[:request_type].present? && params[:request_type] == AllocationsView::RequestType::INITIAL
  end

  def number_of_places_validation_error?
    params[:next_step] == "check_answers" && !form_object.valid?
  end

  def can_proceed_to_number_of_places_page?
    (params[:next_step] == "number_of_places" && params[:request_type].present?) || number_of_places_validation_error?
  end

  def can_proceed_to_check_answers_page?
    params[:next_step] == "check_answers" && params[:number_of_places].present? && form_object.valid?
  end

  def number_of_places_page?
    (params[:step].present? && params[:step] == "number_of_places") || params[:number_of_places].present?
  end

  def check_answers_page?
    params[:step].present? && params[:step] == "check_answers"
  end

  def training_provider
    @training_provider ||= recruitment_cycle.providers.find_by(provider_code: params[:allocation_training_provider_code].upcase)
  end

  def allocation
    @allocation ||= Allocation.includes(:provider, :accredited_body)
                              .find(params[:id])
  end

  def recruitment_cycle
    cycle_year = params[:recruitment_cycle_year] || Settings.current_recruitment_cycle_year

    @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
  end

  def provider
    @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
  end

  def form_object
    if params[:number_of_places]
      number_of_places_form_object
    else
      request_form_object
    end
  end

  def request_form_object
    permitted_params = params
                         .slice(:request_type)
                         .permit(:request_type)

    @request_form_object ||=
      Publish::Allocations::EditInitial::RequestTypeForm.new(permitted_params)
  end

  def number_of_places_form_object
    permitted_params = params
                         .slice(:number_of_places)
                         .permit(:number_of_places)

    @number_of_places_form_object ||= Publish::Allocations::EditInitial::NumberOfPlacesForm.new(permitted_params)
  end
end
