# frozen_string_literal: true

module API
  class SavedCoursesController < PublicAPIController
    def create
      candidate = Candidate.find_by(id: params[:user_id])
      course = Course.find_by(id: params[:course_id])

      if candidate && course
        candidate.saved_courses.find_or_create_by(course_id: course.id)
        render json: { saved: true }, status: :created
      else
        render json: { error: "Invalid candidate or course" }, status: :bad_request
      end
    end

    def destroy
      candidate = Candidate.find_by(id: params[:user_id])
      course = Course.find_by(id: params[:course_id])

      if candidate && course
        candidate.saved_courses.where(course_id: course.id).destroy_all
        render json: { saved: false }, status: :ok
      else
        render json: { error: "Invalid candidate or course" }, status: :bad_request
      end
    end

    def show
      candidate_id = params[:user_id]
      course_id = params[:course_id]

      candidate = Candidate.find_by(id: candidate_id)

      saved = candidate.saved_courses.exists?(course_id: course_id)

      render json: { saved: saved }
    end
  end
end
