module Publish
  class CoursesController < PublishController
    decorates_assigned :course
    include CourseBasicDetailConcern

    def index
      authorize :provider, :index?

      courses_by_accrediting_provider
      self_accredited_courses
    end

    def show
      fetch_course

      authorize @course

      @errors = flash[:error_summary]
      flash.delete(:error_summary)
    end

    def details
      fetch_course

      authorize @course
    end

    def create
      authorize :provider, :index?
      build_new_course

      @course.name = @course.generate_name
      @course.course_code = provider.next_available_course_code

      if @course.save
        flash[:success_with_body] = { title: "Your course has been created", body: "Add the rest of your details and publish the course, so that candidates can find and apply to it." }
        redirect_to(
          publish_provider_recruitment_cycle_courses_path(
            @course.provider_code,
            @course.recruitment_cycle.year,
            @course.course_code,
          ),
        )
      else
        @errors = @course.errors.messages
        @course_creation_params = course_params
        build_new_course

        render :confirmation
      end
    end

    def confirmation
      authorize(provider, :can_create_course?)
      recruitment_cycle
    end

  private

    def fetch_course
      @course = provider.courses.find_by!(course_code: params[:code])
    end

    def provider
      @provider ||= Provider
        .includes(courses: %i[sites site_statuses enrichments provider])
        .find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
    end

    def courses_by_accrediting_provider
      @courses_by_accrediting_provider ||= ::Courses::Fetch.by_accrediting_provider(provider)
    end

    def self_accredited_courses
      @self_accredited_courses ||= courses_by_accrediting_provider.delete(provider.provider_name)
    end
  end
end
