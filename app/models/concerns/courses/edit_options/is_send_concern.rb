module Courses
  module EditOptions
    module IsSendConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in publish-teacher-training:
        #
        # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
        def show_is_send?
          !is_published?
        end
      end
    end
  end
end
