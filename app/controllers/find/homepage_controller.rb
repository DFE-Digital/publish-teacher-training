# frozen_string_literal: true

module Find
  class HomepageController < Find::ApplicationController
    def index
      @search_courses_form = ::Courses::SearchForm.new
    end
  end
end
