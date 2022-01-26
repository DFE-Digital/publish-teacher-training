class PagesController < ApplicationController
  skip_before_action :authenticate, only: %i[
    accessibility
    cookies
    guidance
    performance_dashboard
    privacy
    terms
  ]

  def accessibility; end

  def cookies; end

  def guidance; end

  def performance_dashboard
    @performance_data = PerformanceDashboardService.call
  end

  def privacy; end

  def terms; end
end
