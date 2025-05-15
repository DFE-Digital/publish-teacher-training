module Support
  class FeedbacksController < ApplicationController
    def index
      @pagy, @feedbacks = pagy(Feedback.order(created_at: :desc))
    end
  end
end
