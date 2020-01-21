module Courses
  module EditOptions
    module ApplicationsOpenConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in publish-teacher-training:
        #
        # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
        def show_applications_open?
          !is_published?
        end
      end
    end
  end
end
