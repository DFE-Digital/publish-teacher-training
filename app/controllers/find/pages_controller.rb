class Find::PagesController < ApplicationController
  layout "find_layout"
  skip_before_action :authenticate, only: %i[
    accessibility
    privacy
    terms
  ]

  def accessibility; end

  def privacy; end

  def terms; end
end