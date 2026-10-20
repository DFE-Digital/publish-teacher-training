# frozen_string_literal: true

module Users
  class SortLinksComponent < ViewComponent::Base
    def initialize(sort:, name_path:, last_signed_in_path:)
      super()
      @sort = sort
      @name_path = name_path
      @last_signed_in_path = last_signed_in_path
    end

    def name_selected?
      @sort == "name"
    end

    def last_signed_in_selected?
      @sort == "last_signed_in"
    end
  end
end
