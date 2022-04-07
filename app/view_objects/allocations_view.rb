class AllocationsView
  include ActionView::Helpers::TextHelper

  module Status
    REQUESTED = "REQUESTED".freeze
    NOT_REQUESTED = "NOT REQUESTED".freeze
    YET_TO_REQUEST = "YET TO REQUEST".freeze
    NO_REQUEST_SENT = "NO REQUEST SENT".freeze
  end

  module Colour
    GREEN = "green".freeze
    RED = "red".freeze
    GREY = "grey".freeze
  end

  module Requested
    YES = "yes".freeze
    NO = "no".freeze
  end

  module RequestType
    INITIAL = "initial".freeze
    REPEAT = "repeat".freeze
    DECLINED = "declined".freeze
  end

  def initialize(training_providers:, allocations:)
    @training_providers = training_providers
    @allocations = allocations
  end

  def repeat_allocation_statuses
    filtered_training_providers.map do |training_provider|
      matching_allocation = find_matching_allocation(training_provider, repeat_allocations)
      build_repeat_allocations(matching_allocation, training_provider)
    end
  end

  def initial_allocation_statuses
    statuses = initial_allocations.map do |allocation|
      build_initial_allocations(allocation, allocation.provider)
    end

    statuses.compact
  end

  def requested_allocations_statuses
    statuses = requested_allocations.map do |allocation|
      build_requested_allocations(allocation, allocation.provider)
    end

    statuses.compact.sort_by! { |hsh| hsh[:training_provider_name] }
  end

  def confirmed_allocation_places
    statuses = confirmed_allocations.map do |allocation|
      build_confirmed_allocations(allocation, allocation.provider)
    end

    statuses.compact.sort_by! { |hsh| hsh[:training_provider_name] }
  end

  def not_requested_allocations_statuses
    statuses = filtered_training_providers.map do |training_provider|
      matching_allocation = find_matching_allocation(training_provider, not_requested_allocations)
      build_not_requested_allocations(matching_allocation, training_provider)
    end

    statuses.compact.sort_by! { |hsh| hsh[:training_provider_name] }
  end

private

  def filtered_training_providers
    # When displaying 'repeat allocation statuses'
    # we need to first filter out those training providers
    # who will be allocated places for the first time (i.e. where the accredited provider)
    # has made initial allocation requests on their behalf)
    training_provider_provider_codes = initial_allocations.map { |allocation| allocation.provider.provider_code }
    @training_providers.reject { |tp| training_provider_provider_codes.include?(tp.provider_code) }
  end

  def repeat_allocations
    @allocations.reject { |allocation| allocation.request_type == RequestType::INITIAL }
  end

  def initial_allocations
    @allocations.select { |allocation| allocation.request_type == RequestType::INITIAL }
  end

  def requested_allocations
    @allocations.select { |allocation| allocation.request_type.in?([RequestType::INITIAL, RequestType::REPEAT]) }
  end

  def confirmed_allocations
    @allocations.select { |allocation| allocation.request_type.in?([RequestType::INITIAL, RequestType::REPEAT]) }
  end

  def not_requested_allocations
    @allocations.select { |allocation| allocation.request_type == RequestType::DECLINED }
  end

  def find_matching_allocation(training_provider, allocations)
    allocations.find { |allocation| allocation.provider.provider_code == training_provider.provider_code }
  end

  def build_repeat_allocations(matching_allocation, training_provider)
    allocation_status = {
      training_provider_name: training_provider.provider_name,
      training_provider_code: training_provider.provider_code,
    }

    if yet_to_request?(matching_allocation)
      allocation_status[:status] = Status::YET_TO_REQUEST
      allocation_status[:status_colour] = Colour::GREY
    end

    if requested?(matching_allocation)
      allocation_status[:status] = Status::REQUESTED
      allocation_status[:status_colour] = Colour::GREEN
      allocation_status[:requested] = Requested::YES
    end

    if not_requested?(matching_allocation)
      allocation_status[:status] = Status::NOT_REQUESTED
      allocation_status[:status_colour] = Colour::RED
      allocation_status[:requested] = Requested::NO
    end

    if matching_allocation
      allocation_status[:id] = matching_allocation.id
      allocation_status[:request_type] = matching_allocation.request_type
    end

    if matching_allocation&.accredited_body
      allocation_status[:accredited_body_code] = matching_allocation.accredited_body.provider_code
    end

    allocation_status
  end

  def build_initial_allocations(matching_allocation, training_provider)
    return if matching_allocation.nil?

    hash = {
      training_provider_name: training_provider.provider_name,
      training_provider_code: training_provider.provider_code,
      status_colour: Colour::GREEN,
      requested: Requested::YES,
      request_type: matching_allocation.request_type,
      status: "#{pluralize(matching_allocation.number_of_places, 'place')} requested".upcase,
    }

    hash[:id] = matching_allocation.id if matching_allocation.id

    hash
  end

  def build_confirmed_allocations(allocation, training_provider)
    return if allocation.nil?

    {
      training_provider_name: training_provider.provider_name,
      number_of_places: allocation.number_of_places,
      confirmed_number_of_places: allocation.confirmed_number_of_places,
      uplifts: allocation.allocation_uplift&.uplifts,
      total: allocation.confirmed_number_of_places.to_i + allocation.allocation_uplift&.uplifts.to_i,
    }
  end

  def build_requested_allocations(allocation, training_provider)
    return if allocation.nil?

    {
      training_provider_name: training_provider.provider_name,
      training_provider_code: training_provider.provider_code,
      status_colour: Colour::GREEN,
      status: Status::REQUESTED,
    }
  end

  def build_not_requested_allocations(allocation, training_provider)
    return if training_provider.provider_name.in?(requested_allocations_statuses.map { |tp| tp[:training_provider_name] })

    allocation_status = {
      training_provider_name: training_provider.provider_name,
      training_provider_code: training_provider.provider_code,
    }

    if yet_to_request?(allocation)
      allocation_status[:status] = "NO REQUEST SENT"
      allocation_status[:status_colour] = Colour::GREY
    end

    if not_requested?(allocation)
      allocation_status[:status] = Status::NOT_REQUESTED
      allocation_status[:status_colour] = Colour::RED
    end

    allocation_status
  end

  def not_requested?(matching_allocation)
    matching_allocation && matching_allocation[:request_type] == RequestType::DECLINED
  end

  def requested?(matching_allocation)
    matching_allocation && matching_allocation[:request_type] == RequestType::REPEAT
  end

  def yet_to_request?(matching_allocation)
    matching_allocation.nil?
  end
end
