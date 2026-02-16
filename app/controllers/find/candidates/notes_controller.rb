# frozen_string_literal: true

module Find
  module Candidates
    class NotesController < ApplicationController
      before_action :require_authentication
      before_action :set_saved_course

      def edit
        @editing_note = @saved_course.note.present?
      end

      def update
        @editing_note = @saved_course.note.present?
        note_was_blank = @saved_course.note.blank?
        note_before_edit = @saved_course.note

        return render(:edit, status: :unprocessable_entity) unless saved_course_updated?(note_params)

        if note_was_blank
          send_note_created_analytics_event
        else
          send_note_updated_analytics_event(note_before_edit: note_before_edit)
        end
        flash[:success_with_body] = note_success_flash(course:, note_was_blank:)
        redirect_to_saved_courses
      end

      def destroy
        deleted_note = @saved_course.note

        return redirect_with_note_error(:delete_failed) if deleted_note.blank?
        return redirect_with_note_error(:delete_failed) unless saved_course_updated?(note: nil)

        send_note_deleted_analytics_event(note: deleted_note)
        flash[:success_with_body] = note_deleted_flash(
          course:,
          undo_link: note_undo_link(saved_course: @saved_course, deleted_note:),
        )
        redirect_to_saved_courses
      end

      def undo
        note = params[:note].to_s

        return redirect_with_note_error(:undo_failed) unless note.present? && saved_course_updated?(note: note)

        send_note_undo_analytics_event(note: note)
        redirect_to_saved_courses
      end

    private

      def set_saved_course
        @saved_course = @candidate.saved_courses.find(params[:saved_course_id])
      end

      def course
        @saved_course.course
      end

      def note_params
        params.require(:saved_course).permit(:note)
      end

      def saved_course_updated?(attributes)
        @saved_course.update(attributes)
      end

      def redirect_to_saved_courses
        redirect_to find_candidate_saved_courses_path
      end

      def redirect_with_note_error(error_key)
        redirect_to(
          find_candidate_saved_courses_path,
          flash: { error: note_error_flash(error_key) },
        )
      end

      def note_success_flash(course:, note_was_blank:)
        note_was_blank ? note_added_flash(course) : note_updated_flash(course)
      end

      def note_added_flash(course)
        {
          title: t("find.candidates.saved_courses.update_note.note_added_title"),
          body: t(
            "find.candidates.saved_courses.update_note.note_added_body_html",
            provider_name: course.provider_name,
            course_name_and_code: course.name_and_code,
          ),
        }
      end

      def note_updated_flash(course)
        {
          title: t("find.candidates.saved_courses.update_note.note_updated_title"),
          body: t(
            "find.candidates.saved_courses.update_note.note_updated_body_html",
            provider_name: course.provider_name,
            course_name_and_code: course.name_and_code,
          ),
        }
      end

      def note_undo_link(saved_course:, deleted_note:)
        view_context.render(
          partial: "find/candidates/notes/undo_link",
          locals: { saved_course: saved_course, deleted_note: deleted_note },
        )
      end

      def note_deleted_flash(course:, undo_link:)
        {
          title: t("find.candidates.saved_courses.destroy_note.success_message_title"),
          body: t(
            "find.candidates.saved_courses.destroy_note.success_message_html",
            provider_name: course.provider_name,
            course_name_and_code: course.name_and_code,
            undo_link: undo_link,
          ),
        }
      end

      def note_error_flash(key)
        {
          "message" => t("find.candidates.notes.errors.#{key}"),
        }
      end

      def send_note_created_analytics_event
        send_note_analytics_event(
          Find::Analytics::CandidateNoteCreatedEvent,
          note: @saved_course.note,
        )
      end

      def send_note_updated_analytics_event(note_before_edit:)
        send_note_analytics_event(
          Find::Analytics::CandidateNoteUpdatedEvent,
          note_before_edit: note_before_edit,
          note_after_edit: @saved_course.note,
        )
      end

      def send_note_deleted_analytics_event(note:)
        send_note_analytics_event(
          Find::Analytics::CandidateNoteDeletedEvent,
          note: note,
        )
      end

      def send_note_undo_analytics_event(note:)
        send_note_analytics_event(
          Find::Analytics::CandidateNoteUndoneEvent,
          note: note,
        )
      end

      def send_note_analytics_event(event_class, **extra_attributes)
        event_class.new(
          request:,
          course_id: course.id,
          saved_course_id: @saved_course.id,
          **extra_attributes,
        ).send_event
      end
    end
  end
end
