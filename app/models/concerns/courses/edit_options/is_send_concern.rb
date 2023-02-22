# frozen_string_literal: true

module Courses
  module EditOptions
    module IsSendConcern
      extend ActiveSupport::Concern
      included do
        def show_is_send?
          !is_published?
        end
      end
    end
  end
end
