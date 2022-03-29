module Publish
  class CoursesController < PublishController
    decorates_assigned :course

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

    def new
      authorize(provider, :can_create_course?)
      return render_locations_messages unless provider.sites&.any?

      redirect_to new_publish_provider_recruitment_cycle_courses_level_path(params[:provider_code], @recruitment_cycle.year)
    end

    def create
      authorize(provider, :can_create_course?)
      @course = ::Courses::CreationService.call(course_params: course_params, provider: provider, next_available_course_code: true)

      if @course.save
        flash[:success_with_body] = { title: "Your course has been created", body: "Add the rest of your details and publish the course, so that candidates can find and apply to it." }
        redirect_to(
          publish_provider_recruitment_cycle_courses_path(
            @course.provider_code,
            @course.recruitment_cycle.year,
          ),
        )
      else
        @errors = @course.errors.messages
        @course_creation_params = course_params

        render :confirmation
      end
    end

    def confirmation
      authorize(provider, :can_create_course?)

      @course_creation_params = course_params
      @course = ::Courses::CreationService.call(course_params: course_params, provider: provider)
    end

    def preview
      fetch_course

      authorize @course
    end

    def publish
      fetch_course
      authorize @course

      if @course.publishable?
        publish_course
        flash[:success] = "Your course has been published."

        redirect_to publish_provider_recruitment_cycle_course_path(
          @provider.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
        )
      else
        @errors = format_publish_error_messages

        fetch_course
        render :show
      end
    end

  private

    def course_params
      if params.key? :course
        params.require(:course)
          .permit(
            policy(Course.new).permitted_new_course_attributes,
            sites_ids: [],
            subjects_ids: [],
          )
      else
        ActionController::Parameters.new({}).permit(:course)
      end
    end

    def render_locations_messages
      flash[:error] = { id: "locations-error", message: "You need to create at least one location before creating a course" }

      redirect_to new_publish_provider_recruitment_cycle_location_path(provider.provider_code, provider.recruitment_cycle_year)
    end

    def fetch_course
      @course = provider.courses.find_by!(course_code: params[:code])
    end

    def provider
      @provider ||= recruitment_cycle.providers
        .includes(courses: %i[sites site_statuses enrichments provider])
        .find_by!(provider_code: params[:provider_code])
    end

    def courses_by_accrediting_provider
      @courses_by_accrediting_provider ||= ::Courses::Fetch.by_accrediting_provider(provider)
    end

    def self_accredited_courses
      @self_accredited_courses ||= courses_by_accrediting_provider.delete(provider.provider_name)
    end

    def publish_course
      @course.publish_sites
      @course.publish_enrichment(@current_user)
      NotificationService::CoursePublished.call(course: @course)
    end

    def format_publish_error_messages
      @course.errors.messages.transform_values do |error_messages|
        error_messages.map { |message| message.gsub(/^\^/, "") }
      end
    end
  end
end
