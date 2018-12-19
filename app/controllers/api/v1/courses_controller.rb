module Api
  module V1
    class CoursesController < ApplicationController
      before_action :set_course, only: %i[show update destroy]

      # GET /courses
      def index
        @courses = Course.all

        paginate json: @courses
      end

      # GET /courses/1
      def show
        render json: @course
      end

      # POST /courses
      def create
        @course = Course.new(course_params)

        if @course.save
          render json: @course, status: :created, location: @course
        else
          render json: @course.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /courses/1
      def update
        if @course.update(course_params)
          render json: @course
        else
          render json: @course.errors, status: :unprocessable_entity
        end
      end

      # DELETE /courses/1
      def destroy
        @course.destroy
      end

    private

        # Use callbacks to share common setup or constraints between actions.
      def set_course
        @course = Course.find(params[:id])
      end

        # Only allow a trusted parameter "white list" through.
      def course_params
        params.require(:course).permit(:age_range, :course_code, :name, :profpost_flag, :program_type, :qualification, :start_date, :study_mode, :accrediting_provider_id, :provider_id, :modular, :english, :maths, :science)
      end
    end
  end
end
