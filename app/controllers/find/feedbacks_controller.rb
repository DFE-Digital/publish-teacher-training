module Find
  class FeedbacksController < ApplicationController
    def new
      @feedback = Feedback.new
    end

    def create
      @feedback = Feedback.new(feedback_form_params)

      if @feedback.save
        redirect_to find_root_path, flash: { success: t(".success") }
      else
        render :new
      end
    end

  private

    def feedback_form_params
      params.require(:feedback).permit(:ease_of_use, :experience)
    end
  end
end
