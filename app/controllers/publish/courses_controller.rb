# frozen_string_literal: true

module Publish
  class CoursesController < ApplicationController
    include ApplyRedirect

    decorates_assigned :course

    def index
      authorize :provider, :index?
      all_courses = provider.courses

      @show_summary_parts = {
        qualification:
          varying_column?(all_courses, :qualification),

        study_mode:
          varying_column?(all_courses.where.not(study_mode: nil), :study_mode),
      }

      @show_funding =
        varying_column?(all_courses, :funding)

      @show_start_date =
        varying_column?(all_courses, :start_date)

      # Decide whether to show the "Course information" column at all
      @show_course_info_column =
        @show_funding ||
        @show_start_date ||
        @show_summary_parts.values.any?

      # Which filters should beshown to users
      @show_filters = {
        funding: varying_column?(all_courses, :funding),
        qualification: varying_column?(all_courses, :qualification),
        study_mode: varying_column?(all_courses, :study_mode),
        start_date: varying_column?(all_courses, :start_date),
      }

      # Always show filters that are currently applied
      @show_filters[:funding] ||= params[:funding].present?
      @show_filters[:qualification] ||= params[:qualification].present?
      @show_filters[:study_mode] ||= params[:study_mode].present?
      @show_filters[:start_date] ||= params[:start_date].present?

      courses_by_accrediting_provider
      self_accredited_courses

      # Set active filters for display in the view
      @active_filters = []

      if params[:funding].present?
        Array(params[:funding]).each do |value|
          @active_filters << {
            key: :funding,
            value: value,
            label: value.humanize,
          }
        end
      end

      if params[:status].present?
        Array(params[:status]).each do |value|
          @active_filters << {
            key: :status,
            value: value,
            label: value.humanize,
          }
        end
      end

      if params[:education_phase].present?
        Array(params[:education_phase]).each do |value|
          @active_filters << {
            key: :education_phase,
            value: value,
            label: value.humanize,
          }
        end
      end

      if params[:qualification].present?
        Array(params[:qualification]).each do |value|
          @active_filters << {
            key: :qualification,
            value: value,
            label: value == "qts" ? "QTS only" : "QTS with PGCE or PGDE",
          }
        end
      end

      if params[:study_mode].present?
        Array(params[:study_mode]).each do |value|
          @active_filters << {
            key: :study_mode,
            value: value,
            label: value.humanize,
          }
        end
      end

      @start_month_options =
        provider.courses
                .pluck(:start_date)
                .compact
                .map(&:beginning_of_month)
                .uniq
                .sort

      if params[:start_date].present?
        Array(params[:start_date]).each do |value|
          label = Date.strptime(value, "%Y-%m").strftime("%B %Y")

          @active_filters << {
            key: :start_date,
            value: value,
            label: label,
          }
        end
      end

      # CSV export of course information, WITH any filters applied
      respond_to do |format|
        format.html
        format.csv do
          export = Publish::DataExports::CourseInformationExport.new(
            courses: filtered_courses,
            provider: provider,
            params: params,
          )

          begin
            send_data export.to_csv,
                      filename: export.filename,
                      type: "text/csv",
                      disposition: :attachment
          rescue StandardError => e
            Rails.logger.error("CSV export failed: #{e.message}")
            Sentry.capture_exception(e)

            redirect_to publish_provider_recruitment_cycle_courses_path(
              provider.provider_code,
              provider.recruitment_cycle_year,
            ), flash: { alert: "Unable to download course data" }
          end
        end
      end
    end

    def show
      fetch_course

      authorize @course

      @errors = flash[:error_summary]
      flash.delete(:error_summary)
    end

    def details
      fetch_course

      if show_errors_on_publish?
        @course.valid?(:publish)
        @errors = format_publish_error_messages
      end

      authorize @course
    end

    def new
      authorize(provider, :can_create_course?)
      return render_schools_messages unless provider.sites&.any?

      redirect_to new_publish_provider_recruitment_cycle_courses_level_path(params[:provider_code], @recruitment_cycle.year)
    end

    def create
      authorize(provider, :can_create_course?)
      @course = ::Courses::CreationService.call(course_params:, provider:, next_available_course_code: true)

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
      @course = ::Courses::CreationService.call(course_params:, provider:)
    end

    def preview
      fetch_course
      @provider = provider
      @course = @course.decorate

      @enrichment = @course.latest_unpublished_enrichment || @course.enrichments.find_or_initialize_draft

      authorize @course
    end

    def publish
      fetch_course_with_latest_draft_enrichment_eager_loaded
      authorize @course

      if ::Courses::PublishService.new(course: @course, user: @current_user).call
        flash[:success] = render_flash_message_content

        redirect_to publish_provider_recruitment_cycle_course_path(
          @provider.provider_code,
          @course.recruitment_cycle_year,
          @course.course_code,
        )
      else
        @errors = format_publish_error_messages

        if @errors.key?(:sites)
          @current_tab = :details
          render :details
        else
          @current_tab = :description
          render :show
        end
      end
    end

  private

    def render_flash_message_content
      @course.scheduled? ? "Your course has been scheduled." : "Your course has been published."
    end

    def course_params
      if params.key? :course
        params
          .expect(
            course: [policy(Course.new).permitted_new_course_attributes,
                     { study_mode: [],
                       sites_ids: [],
                       subjects_ids: [],
                       study_sites_ids: [] }],
          )
      else
        ActionController::Parameters.new({}).permit(:course)
      end
    end

    def render_schools_messages
      flash[:error] = { id: "schools-error", message: "You need to create at least one school before creating a course" }

      redirect_to new_publish_provider_recruitment_cycle_school_path(provider.provider_code, provider.recruitment_cycle_year)
    end

    def fetch_course_with_latest_draft_enrichment_eager_loaded
      @course = provider.courses.includes(
        :latest_draft_enrichment,
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find_by!(course_code: params[:code])
    end

    def fetch_course
      @course = provider.courses.includes(
        :enrichments,
        subjects: [:financial_incentive],
        site_statuses: [:site],
      ).find_by!(course_code: params[:code])
    end

    def provider
      @provider ||= recruitment_cycle.providers
                                     .find_by!(provider_code: params[:provider_code])
    end

    def courses_by_accrediting_provider
      @courses_by_accrediting_provider ||= filtered_courses.group_by do |course|
        course.accrediting_provider&.provider_name || provider.provider_name
      end
    end

    def self_accredited_courses
      @self_accredited_courses ||= courses_by_accrediting_provider.delete(provider.provider_name)
    end

    def format_publish_error_messages
      @course.errors.messages.transform_values do |error_messages|
        error_messages.map { |message| message.gsub(/^\^/, "") }
      end
    end

    # The status matchers are used to filter courses by their status in the index action. They are defined as lambdas that take a course and return true if the course matches the status.
    STATUS_MATCHERS = {
      "open" => lambda { |c|
        c.open_for_applications?
      },

      "closed" => lambda { |c|
        c.only_published? &&
          !c.open_for_applications? &&
          !c.is_withdrawn?
      },

      "draft" => lambda { |c|
        c.content_status == :draft
      },

      "rolled_over" => lambda { |c|
        c.content_status == :rolled_over
      },

      "scheduled" => lambda { |c|
        c.scheduled?
      },

      "withdrawn" => lambda { |c|
        c.is_withdrawn?
      },
    }.freeze

    # The filtered_courses method is used to filter courses by the selected filters in the index action. It applies the filters to the courses and returns the filtered courses.
    def filtered_courses
      @filtered_courses ||= begin
        courses = filtered_courses_scope.includes(:accrediting_provider, site_statuses: [:site])

        if params[:status].present?
          selected = Array(params[:status])
          courses = courses.includes(:latest_enrichment, :enrichments, site_statuses: :site).to_a.select do |course|
            selected.any? do |status|
              matcher = STATUS_MATCHERS[status]
              matcher && matcher.call(course)
            end
          end
        else
          courses = courses.to_a
        end

        courses
          .map(&:decorate)
          .sort_by { |course| course.name.downcase }
      end
    end

    def filtered_courses_scope
      courses = provider.courses

      courses = courses.where(level: params[:education_phase]) if params[:education_phase].present?
      courses = courses.where(funding: params[:funding]) if params[:funding].present?
      courses = courses.where(qualification: params[:qualification]) if params[:qualification].present?
      courses = courses.where(study_mode: params[:study_mode]) if params[:study_mode].present?
      courses = courses.with_start_months(params[:start_date]) if params[:start_date].present?
      courses
    end

    def varying_column?(scope, column_name)
      scope.reselect(column_name).distinct.limit(2).pluck(column_name).size > 1
    end

    def filters_applied?
      params.slice(
        :status,
        :education_phase,
        :funding,
        :qualification,
        :study_mode,
        :start_date,
      ).values.any?(&:present?)
    end
  end
end
