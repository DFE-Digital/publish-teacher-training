module V3
  class CourseSearchService
    def initialize(filter: nil, sort: nil, course_scope: Course)
      @filter = filter
      @sort = sort
      @course_scope = course_scope
    end

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def call
      ::CourseSearchService.call(
        filter:,
        sort:,
        course_scope:,
      )
    end

    private_class_method :new

  private

    attr_reader :sort, :filter, :course_scope
  end
end
