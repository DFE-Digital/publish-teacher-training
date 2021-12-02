module PagyPagination
  extend ActiveSupport::Concern

  def jsonapi_links
    pagy_results.present? ? pagination_links : {}
  end

  def paginate(scope)
    @pagy_results ||= pagy(scope, items: per_page, page: page)

    pagy_results.second
  end

private

  attr_accessor :pagy_results

  def pagination_links
    meta = pagy_metadata(pagy_results.first, absolute: true)

    {
      first: meta[:first_url],
      last: meta[:last_url],
      prev: meta[:prev].nil? ? nil : meta[:prev_url],
      next: meta[:next].nil? ? nil : meta[:next_url],
    }
  end

  def per_page
    [(per_page_parameter || default_per_page).to_i, max_per_page].min
  end

  def default_per_page
    100
  end

  def max_per_page
    500
  end

  def page
    (page_parameter || 1).to_i
  end

  def page_parameter
    return params[:page][:page] if page_is_nested?

    params[:page]
  end

  def per_page_parameter
    return params[:page][:per_page] if page_is_nested?

    params[:per_page]
  end

  def page_is_nested?
    params[:page].is_a?(ActionController::Parameters)
  end
end
