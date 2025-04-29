module Find
  class FeedbacksController < ApplicationController
    def new
      @feedback_form = FeedbackForm.new
    end

    def create
      @feedback_form = FeedbackForm.new(feedback_form_params)
      @feedback = Feedback.new(feedback_attributes)

      if @feedback_form.invalid?
        render :new
      else
        @feedback.save
        flash[:success] = t(".success")
        redirect_to find_root_path
      end
    end

  private

    def feedback_form_params
      params.fetch(:find_feedback_form, {}).permit(:ease_of_use, :experience)
    end

    def feedback_attributes
      feedback_form_params
    end
  end
end
