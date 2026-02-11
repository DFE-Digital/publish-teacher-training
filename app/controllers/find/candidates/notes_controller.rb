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

        if @saved_course.update(note_params)
          flash[:success_with_body] = note_success_flash(course: @saved_course.course, note_was_blank:)
          redirect_to find_candidate_saved_courses_path
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        deleted_note = @saved_course.note
        @saved_course.update!(note: nil)

        undo_link = note_undo_link(saved_course: @saved_course, deleted_note:)
        flash[:success_with_body] = note_deleted_flash(course: @saved_course.course, undo_link:)

        redirect_to find_candidate_saved_courses_path
      end

      def undo
        note = params[:note].to_s
        @saved_course.update(note: note) if note.present?

        redirect_to find_candidate_saved_courses_path
      end

    private

      def set_saved_course
        @saved_course = @candidate.saved_courses.find(params[:saved_course_id])
      end

      def note_params
        params.require(:saved_course).permit(:note)
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
    end
  end
end
