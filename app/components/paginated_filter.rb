# frozen_string_literal: true

class PaginatedFilter < ViewComponent::Base
  attr_reader :filter_params, :collection, :pagy

  def initialize(filter_params:, collection:, pagy:)
    super
    @filter_params = filter_params
    @collection = collection
    @pagy = pagy
  end

  def filters
    filter_params.slice(*allowed_search_params_keys)
  end

private

  def allowed_search_params_keys
    {
      User: %i[text_search user_type],
      Provider: %i[provider_search course_search accredited provider_type],
      Candidate: %i[text_search],
    }[collection.klass.name.to_sym]
  end
end
