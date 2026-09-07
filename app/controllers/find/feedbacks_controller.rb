module Find
  class FeedbacksController < ApplicationController
    invisible_captcha only: :create,
                      honeypot: :subject,
                      scope: :feedback,
                      on_spam: :discard_spam

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
    rescue ArgumentError
      @feedback = Feedback.new
      render :new
    end

  private

    def discard_spam
      redirect_to find_root_path, flash: { success: t("find.feedbacks.create.success") }
    end

    def feedback_form_params
      params.require(:feedback).permit(:ease_of_use, :experience)
    end
  end
end
