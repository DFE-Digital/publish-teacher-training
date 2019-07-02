# coding: utf-8

module API
  module V2
    class CoursesController < API::V2::ApplicationController
      before_action :build_recruitment_cycle
      before_action :build_provider
      before_action :build_course, except: :index

      deserializable_resource :course,
                              only: %i[update publish publishable],
                              class: API::V2::DeserializableCourse

      def index
        authorize @provider, :can_list_courses?
        authorize Course

        render jsonapi: @provider.courses, include: params[:include]
      end

      def show
        render jsonapi: @course, include: params[:include]
      end

      def sync_with_search_and_compare
        if @course.syncable?
          response = SearchAndCompareAPIService::Request.sync(
            [@course]
          )
          if response
          else
            raise RuntimeError.new(
              'error received when syncing with search and compare'
            )
          end
        end
      end

      def publish
        if @course.publishable?
          @course.publish_sites
          @course.publish_enrichment(@current_user)
          if @course.syncable?
            has_synced = SearchAndCompareAPIService::Request.sync(
              [@course]
            )
            if has_synced
              head :ok
            else
              raise RuntimeError.new(
                'error received when syncing with search and compare'
              )
            end
          else
            raise RuntimeError.new(
              'course is not syncable'
            )
          end
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
        update_enrichment
        update_sites

        if @course.errors.empty? && @course.valid?
          render jsonapi: @course.reload
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

    private

      def update_enrichment
        return unless enrichment_params.values.any?

        enrichment = @course.enrichments.find_or_initialize_draft
        enrichment.assign_attributes(enrichment_params)
        enrichment.save
      end

      def update_sites
        return if site_ids.nil?

        @course.sites = @provider.sites.where(id: site_ids) if site_ids.any?
        # This validation is done at the controller level instead of the model.
        # This is because sites = [] is something that we can validate against,
        # but we can't actually revert easily from what I can tell because of the
        # remove_site! side effects that occur when it's called.
        @course.errors[:sites] << "^You must choose at least one location" if site_ids.empty?

        sync_with_search_and_compare if site_ids.any?
      end

      def build_provider
        @provider = @recruitment_cycle.providers.find_by!(
          provider_code: params[:provider_code].upcase
        )
      end

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year]
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_course
        @course = @provider.courses.find_by!(course_code: params[:code].upcase)

        authorize @course
      end

      def enrichment_params
        params
          .fetch(:course, {})
          .except(:id, :type, :sites_ids, :sites_types)
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
            :qualifications
          )
      end

      def site_ids
        params.fetch(:course, {})[:sites_ids]
      end
    end
  end
end
