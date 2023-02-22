# frozen_string_literal: true

module Courses
  module EditOptions
    module ApplicationsOpenConcern
      extend ActiveSupport::Concern
      included do
        def show_applications_open?
          !is_published?
        end
      end
    end
  end
end
