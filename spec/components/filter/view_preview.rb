# frozen_string_literal: true

module Filters
  class ViewPreview < ViewComponent::Preview
    def show_filter
      render(Filters::View.new(filters: filters, filter_model: filter_model))
    end

  private

    def filters
      @filters ||= nil
    end

    def filter_model
      @filter_model ||= [Provider, User, Allocation].sample
    end
  end
end
