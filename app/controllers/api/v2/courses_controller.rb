# coding: utf-8

module API
  module V2
    class CoursesController < API::V2::ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider
      before_action :build_filter, only: :index
      before_action :build_course, except: %i[index new create build_new]

      deserializable_resource :course,
                              only: %i[update publish publishable create],
                              class: API::V2::DeserializableCourse

      def new
        authorize Course

        @course = @provider.courses.new

        render jsonapi: @course, include: params[:include]
      end

      def build_new
        authorize @provider
        build_new_course
        @course.valid?(:new)

        # https://github.com/jsonapi-rb/jsonapi-rails/issues/113
        json_data = JSONAPI::Serializable::Renderer.new.render(
          @course,
          class: CourseSerializersService.new.execute,
          include: [:subjects, :sites, :accrediting_provider, :provider, provider: [:sites]],
        )

        unless @current_user.admin?
          json_data[:data][:meta][:edit_options][:subjects]&.reject! do |subject|
            subject[:attributes][:subject_name] == "Physical education"
          end
        end

        json_data[:data][:errors] = []

        @course.errors.messages.each do |error_key, _|
          @course.errors.full_messages_for(error_key).each do |error_message|
            json_data[:data][:errors] << {
              "title" => "Invalid #{Course.human_attribute_name(error_key).downcase}",
              "detail" => error_message,
              "source" => { "pointer" => "/data/attributes/#{error_key}" },
            }
          end
        end

        render json: json_data
      end

      def index
        authorize Course

        scope = policy_scope(Course).kept
        scope = scope.where(provider_id: @provider.id) if @provider.present?
        scope = scope.with_recruitment_cycle(@recruitment_cycle.year)
        scope = scope.with_accredited_bodies(accredited_bodies) if accredited_bodies.present?

        render jsonapi: scope, include: params[:include], class: CourseSerializersService.new.execute
      end

      def show
        # https://github.com/jsonapi-rb/jsonapi-rails/issues/113
        render jsonapi: @course, include: params[:include], class: CourseSerializersService.new.execute
      end

      def publish
        if @course.publishable?
          @course.publish_sites
          @course.publish_enrichment(@current_user)
          @course.reload
          NotificationService::CoursePublished.call(course: @course)

          head :ok
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

      def publishable
        if @course.publishable?
          head :ok
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

      def update
        update_course
        update_enrichment
        update_sites
        update_subjects

        @course.ensure_site_statuses_match_study_mode if @course.study_mode_previously_changed?

        if @course.errors.empty? && @course.valid?
          @course.save

          unless site_ids.nil?
            NotificationService::CourseSitesUpdated.call(
              course: @course,
              previous_site_names: @previous_site_names,
              updated_site_names: @updated_site_names,
            )
          end

          @course.course_subjects.each(&:save)

          render jsonapi: @course.reload
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @course.discard
      end

      def withdraw
        authorize @course
        if @course.is_published?
          @course.withdraw
          NotificationService::CourseWithdrawn.call(course: @course)
        else
          raise RuntimeError.new("This course has not been published and should be deleted not withdrawn")
        end
      end

      def create
        authorize @provider, :can_create_course?
        return unless course_params.values.any?

        build_new_course
        course_code = @provider.next_available_course_code
        @course.assign_attributes(course_code: course_code)

        create_new_course
      end

      def send_vacancies_filled_notification
        authorize @course
        NotificationService::CourseVacanciesFilled.call(course: @course)
      end

    private

      def update_enrichment
        return unless enrichment_params.values.any?

        enrichment = @course.enrichments.find_or_initialize_draft
        enrichment.assign_attributes(enrichment_params)
        enrichment.status = :draft if enrichment.rolled_over?
        enrichment.save
      end

      def update_course
        return unless course_params.values.any? || funding_type_params.present?
        return unless @course.course_params_assignable(course_params)

        @course.assign_attributes(course_params)
        @course.save

        NotificationService::CourseUpdated.call(course: @course)
      end

      def update_sites
        return if site_ids.nil?

        @previous_site_names = @course.sites.map(&:location_name)

        @course.sites = @provider.sites.where(id: site_ids) if site_ids.any?
        # This validation is done at the controller level instead of the model.
        # This is because sites = [] is something that we can validate against,
        # but we can't actually revert easily from what I can tell because of the
        # remove_site! side effects that occur when it's called.
        @course.errors[:sites] << "^You must choose at least one location" if site_ids.empty?
        @updated_site_names = @course.sites.map(&:location_name) unless site_ids.empty?
      end

      def update_subjects
        return if subject_ids.nil?

        if request_has_duplicate_subject_ids?
          @course.errors.add(:subjects, :duplicate)
        else
          @course.subjects = []

          @course.subjects = Subject.find(subject_ids)

          subject_ids.each_with_index do |id, index|
            @course.course_subjects.select { |cs| cs.subject_id == id.to_i }.first.position = index
          end

          @course.name = @course.generate_name
        end
      end

      def build_provider
        return if params[:provider_code].blank?

        @provider = @recruitment_cycle.providers.find_by!(
          provider_code: params[:provider_code].upcase,
        )
      end

      def build_filter
        @filter = {}
        @filter = params[:filter] if params[:filter].present?
      end

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_course
        @course = @provider.courses.find_by!(course_code: params[:code].upcase)

        authorize @course
      end

      def build_new_course
        @course = Course.new(provider: @provider)
        @course.assign_attributes(course_params)
        update_subjects
        update_sites
        update_further_education_fields if @course.level == "further_education"
        @course.name = @course.generate_name
      end

      def enrichment_params
        params
          .fetch(:course, {})
          .except(:id,
                  :type,
                  :sites_ids,
                  :sites_types,
                  :english,
                  :maths,
                  :science,
                  :qualification,
                  :age_range_in_years,
                  :start_date,
                  :applications_open_from,
                  :study_mode,
                  :is_send,
                  :accredited_body_code,
                  :funding_type,
                  :name,
                  :course_code,
                  :subjects_ids,
                  :subjects_types,
                  :level)
          .permit(
            :about_course,
            :course_length,
            :fee_details,
            :fee_international,
            :fee_uk_eu,
            :financial_support,
            :how_school_placements_work,
            :interview_process,
            :other_requirements,
            :personal_qualities,
            :salary_details,
            :required_qualifications,
          )
      end

      def course_params
        params
          .fetch(:course, {})
          .except(:about_course,
                  :course_length,
                  :fee_details,
                  :fee_international,
                  :fee_uk_eu,
                  :financial_support,
                  :how_school_placements_work,
                  :interview_process,
                  :other_requirements,
                  :personal_qualities,
                  :salary_details,
                  :required_qualifications,
                  :qualifications,
                  :id,
                  :type,
                  :sites_ids,
                  :sites_types,
                  :course_code,
                  :subjects_ids,
                  :subjects_types)
          .permit(policy(Course.new).permitted_attributes)
      end

      def update_further_education_fields
        @course.funding_type = "fee"
        @course.subjects << FurtherEducationSubject.instance
      end

      def site_ids
        params.fetch(:course, {})[:sites_ids]
      end

      def funding_type_params
        params.fetch(:course, {})[:funding_type]
      end

      def subject_ids
        params.fetch(:course, {})[:subjects_ids]
      end

      def create_new_course
        if @course.valid?(:new) && @course.save
          render jsonapi: @course.reload
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

      def request_has_duplicate_subject_ids?
        subject_ids.uniq.count != subject_ids.count
      end

      def accredited_bodies
        return [] if @filter[:accredited_body_code].blank?

        @filter[:accredited_body_code]
      end
    end
  end
end
