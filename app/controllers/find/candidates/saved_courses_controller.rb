module Find
  module Candidates
    class SavedCoursesController < ApplicationController
      before_action :require_authentication
      after_action :send_saved_course_analytics_event, only: [:create]
      after_action :send_remove_saved_course_analytics_event, only: [:destroy]
      skip_before_action :require_authentication, only: %i[sign_in]
      before_action :assign_saved_courses, only: :index

      def index
        not_found if @pagy.overflow?
      end

      def sign_in
        @course = Course.find(params[:course_id])
        @login_path = Settings.one_login.enabled ? "/auth/one-login" : "/auth/find-developer"
        @return_to = safe_results_return_to(params[:return_to])
      end

      def after_auth
        intent = extract_save_course_intent
        return redirect_to(find_root_path) if intent[:course_id].blank?
        return redirect_to(find_root_path, flash: { error: save_failed_flash }) if intent[:invalid_return_to]

        @course = Course.find_by(id: intent[:course_id])
        return redirect_to(find_root_path, flash: { error: save_failed_flash }) unless @course

        if save_course_for_candidate(@course)
          flash[:success_with_body] = course_saved_flash(@course)
          send_saved_course_analytics_event
        else
          flash[:error] = save_failed_flash
        end

        redirect_after_save(@course, intent[:return_to])
      end

      def create
        saved_course = SaveCourseService.call(candidate: @candidate, course:)

        respond_to do |format|
          if saved_course
            format.html { redirect_to_course(course) }
            format.json { render json: { saved_course: saved_course.id }, status: :created }
          else
            format.html { redirect_to_course(course, error: t(".save_failed")) }
            format.json { render json: { error: t(".save_failed") }, status: :unprocessable_entity }
          end
        end
      end

      def undo
        if SaveCourseService.call(candidate: @candidate, course:)
          redirect_to find_candidate_saved_courses_path(saved_courses_filter_params)
        else
          redirect_to find_candidate_saved_courses_path(saved_courses_filter_params.merge(error: t(".save_failed")))
        end
      end

      def destroy
        saved_course = @candidate.saved_courses.find(params[:id])
        @course = saved_course.course

        respond_to do |format|
          if saved_course.destroy
            format.json { render json: { deleted: true }, status: :ok }

            format.html do
              if params[:unsaved_course_on_show_page]
                redirect_to_course(@course)
              else
                undo_link = view_context.render(
                  partial: "find/candidates/saved_courses/undo_link",
                  locals: { label: t(".undo"), undo_path: undo_find_candidate_saved_courses_path, course: @course, location: params[:location], order: params[:order] },
                )

                flash[:success_with_body] = {
                  title: t(".success_message_title"),
                  body: t(
                    ".success_message_html",
                    provider_name: @course.provider_name,
                    course_name_and_code: @course.name_and_code,
                    undo_link: undo_link,
                  ),
                }

                redirect_to find_candidate_saved_courses_path(saved_courses_filter_params)
              end
            end
          else
            format.json { render json: { error: t(".unsave_failed") }, status: :unprocessable_entity }

            format.html { redirect_to_course(@course, error: t(".unsave_failed")) }
          end
        end
      end

    private

      def course
        @course ||= Course.find(params[:course_id])
      end

      def assign_saved_courses
        @location = saved_courses_filter_params[:location]
        @address = Geolocation::Address.query(@location) if @location.present?

        query_params = saved_courses_query_params
        saved_courses_query = SavedCourses::Query.new(candidate: @candidate, params: query_params)
        saved_courses = saved_courses_query.call
        @pagy, @saved_courses = pagy(saved_courses, count: saved_courses_query.count)
        @short_address = @address&.short_address
        @order = query_params[:order]
      end

      def send_saved_course_analytics_event
        Analytics::SavedCourseEvent.new(
          request:,
          course_id: @course.id,
        ).send_event
      end

      def send_remove_saved_course_analytics_event
        Analytics::RemoveSavedCourseEvent.new(
          request:,
          course_id: @course.id,
        ).send_event
      end

      def redirect_to_course(course, error: nil)
        options = {
          provider_code: course.provider_code,
          course_code: course.course_code,
        }

        flash_options = error ? { flash: { error: { message: error } } } : {}
        redirect_to find_course_path(**options), **flash_options
      end

      def course_saved_flash(course)
        view_saved_courses_link = view_context.govuk_link_to(
          t("find.candidates.saved_courses.create.view_saved_courses"),
          find_candidate_saved_courses_path,
        )

        {
          title: t("find.candidates.saved_courses.create.success_message_title"),
          body: t(
            "find.candidates.saved_courses.create.success_message_html",
            provider_name: course.provider_name,
            course_name_and_code: course.name_and_code,
            view_saved_courses_link: view_saved_courses_link,
          ),
        }
      end

      def save_failed_flash
        { message: t("find.candidates.saved_courses.after_auth.save_failed") }
      end

      def extract_save_course_intent
        course_id = session.delete("save_course_id_after_authenticating")
        invalid_return_to = session.delete("save_course_return_to_invalid_after_authenticating").present?
        return_to = safe_results_return_to(session.delete("save_course_return_to_after_authenticating"))

        {
          course_id: course_id,
          invalid_return_to: invalid_return_to,
          return_to: return_to,
        }
      end

      def save_course_for_candidate(course)
        SaveCourseService.call(candidate: @candidate, course: course).present?
      end

      def redirect_after_save(course, return_to)
        if return_to.present?
          redirect_to return_to, allow_other_host: false
        else
          redirect_to_course(course)
        end
      end

      def safe_results_return_to(value)
        return nil unless value.is_a?(String)
        return nil unless value.start_with?("/results")
        return nil if value.start_with?("//")

        value
      end

      def saved_courses_query_params
        permitted = saved_courses_filter_params.except(:location).symbolize_keys

        if @address&.latitude.present?
          permitted.merge(latitude: @address.latitude, longitude: @address.longitude)
        else
          permitted
        end
      end

      def saved_courses_filter_params
        params.permit(:location, :order).to_h.compact_blank
      end

      def reason_for_request
        :general
      end
    end
  end
end
