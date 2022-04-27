class InitialRequestFlow
  include Rails.application.routes.url_helpers

  PE_SUBJECT_CODE = "C6".freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  # rubocop:disable Lint/DuplicateBranch: Duplicate branch body detected
  def template
    if check_your_information_page?
      "publish/providers/allocations/check_your_information"
    elsif number_of_places_page? || number_of_places_zero?
      "publish/providers/allocations/number_of_places"
    elsif blank_search_query? || empty_search_results?
      "publish/providers/allocations/initial_request"
    elsif pick_a_provider_page?
      "publish/providers/allocations/pick_a_provider"
    else
      "publish/providers/allocations/initial_request"
    end
  end
  # rubocop:enable Lint/DuplicateBranch: Duplicate branch body detected

  # rubocop:disable Lint/DuplicateBranch: Duplicate branch body detected
  def locals
    if number_of_places_page? || check_your_information_page?
      {
        training_provider: training_provider,
        form_object: form_object,
      }
    elsif blank_search_query? || empty_search_results?
      {
        training_providers: training_providers_without_associated,
        form_object: form_object,
        provider: provider,
      }
    elsif pick_a_provider_page?
      {
        training_providers: training_providers_from_query,
      }
    else
      {
        training_providers: training_providers_without_associated,
        form_object: form_object,
        provider: provider,
      }
    end
  end
  # rubocop:enable Lint/DuplicateBranch: Duplicate branch body detected

  def redirect?
    return false if valid_number_of_places?

    (training_provider_search? && one_search_result?) || training_provider_selected?
  end

  def allocation
    if (training_provider_search? && one_search_result?) || training_provider_selected?

      allocations.find_by(provider_code: training_provider[:provider_code])
    end
  end

  def redirect_path
    if allocation
      edit_provider_recruitment_cycle_allocation_path(
        provider.provider_code,
        provider.recruitment_cycle_year,
        training_provider.provider_code,
        id: allocation[:id],
      )
    elsif (training_provider_search? && one_search_result?) || training_provider_selected?
      initial_request_publish_provider_recruitment_cycle_allocations_path(
        provider_code: provider.provider_code,
        recruitment_cycle_year: recruitment_cycle.year,
        training_provider_code: training_provider[:provider_code],
      )
    end
  end

  delegate :valid?, to: :form_object

private

  def valid_number_of_places?
    params[:number_of_places] && /\A\d+\z/.match?(params[:number_of_places]) && params[:number_of_places].to_i.positive?
  end

  def number_of_places_zero?
    params[:number_of_places]&.to_i&.zero?
  end

  def training_provider_selected?
    params[:training_provider_code].present? && params[:training_provider_code] != "-1"
  end

  def training_provider_search?
    params[:training_provider_code] == "-1" && params[:training_provider_query].present? && params[:training_provider_query].size > 1
  end

  def one_search_result?
    training_providers_from_query.count == 1
  end

  def form_object
    permitted_params = params.slice(:training_provider_code, :training_provider_query, :number_of_places)
                             .permit(:training_provider_code, :training_provider_query, :number_of_places)

    @form_object ||= Publish::InitialRequestForm.new(permitted_params)
  end

  def allocations
    @allocations ||= Allocation.includes(:provider, :accredited_body)
    .current_allocations.where(accredited_body_code: provider.provider_code)
  end

  def training_provider_search_service
    API::V2::AccreditedProviderTrainingProvidersController::TrainingProviderSearch
  end

  def training_providers_with_fee_paying_pe_course
    @training_providers_with_fee_paying_pe_course ||=

      training_provider_search_service.new(
        provider: provider, params: { filter: { subjects: PE_SUBJECT_CODE,
                                                funding_type: "fee" } }
      ).call
  end

  def all_training_providers
    @all_training_providers ||= training_provider_search_service.new(provider: provider, params: {}).call
  end

  def training_providers_with_previous_allocations
    @training_providers_with_previous_allocations ||= allocations.map(&:provider)
  end

  def associated_training_providers
    training_providers_with_previous_allocations + training_providers_with_fee_paying_pe_course
  end

  def training_providers_without_associated
    return @training_providers_without_associated if @training_providers_without_associated

    ids_to_reject = associated_training_providers.map(&:id)

    @training_providers_without_associated = all_training_providers.reject do |provider|
      ids_to_reject.include?(provider.id)
    end
  end

  def training_providers_from_query
    return @training_providers_from_query if @training_providers_from_query

    query = params[:training_provider_query]

    @training_providers_from_query ||= recruitment_cycle.providers
    .provider_search(query)
    .limit(5)
  end

  def training_providers_from_query_without_associated
    ids_to_reject = associated_training_providers.map(&:id)

    training_providers_from_query.reject do |r|
      ids_to_reject.include?(r.id)
    end
  end

  def recruitment_cycle
    cycle_year = params[:recruitment_cycle_year] || Settings.current_recruitment_cycle_year

    @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
  end

  def provider
    @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
  end

  def empty_search_results?
    return @empty_search_results if @empty_search_results

    @empty_search_results = training_provider_search? && training_providers_from_query_without_associated.empty?

    form_object.add_no_results_error if @empty_search_results

    @empty_search_results
  end

  def pick_a_provider_page?
    training_provider_search? && training_providers_from_query.count > 1
  end

  def number_of_places_page?
    training_provider_selected? ||
      (params[:training_provider_query].present? && params[:training_provider_query].size > 1 && one_search_result?) || params[:change]
  end

  def check_your_information_page?
    training_provider_selected? && valid_number_of_places? && !params[:change]
  end

  def training_provider
    @training_provider ||= if params[:training_provider_code] == "-1"
                             training_providers_from_query.first
                           else
                             recruitment_cycle.providers.find_by(provider_code: params[:training_provider_code].upcase)
                           end
  end

  def blank_search_query?
    params[:training_provider_code] == "-1" && params[:training_provider_query].blank?
  end
end
