module Support
  class FeedbacksController < ApplicationController
    def index
      @pagy, @feedbacks = pagy(Feedback.order(created_at: :desc))

      respond_to do |format|
        format.html
        format.csv do
          export = Support::DataExports::FeedbackExport.new
          begin
            send_data export.to_csv,
                      filename: export.filename,
                      type: "text/csv",
                      disposition: :attachment
          rescue StandardError => e
            Rails.logger.error("CSV export failed: #{e.message}")
            Sentry.capture_exception(e)
            flash[:alert] = "Unable to download feedback data. Error: #{e.message}"
            redirect_to support_feedback_index_path
          end
        end
      end
    end

    def show
      @feedback = Feedback.find(params[:id])
    end

    def delete_multiple
      @feedbacks = Feedback.where(id: params[:feedback_ids])

      if @feedbacks.empty?
        redirect_to support_feedback_index_path, flash: { warning: "No feedback selected" }
      end
    end

    def destroy_multiple
      feedbacks = Feedback.where(id: params[:feedback_ids])
      count = feedbacks.count

      feedbacks.destroy_all

      redirect_to support_feedback_index_path, flash: { success: "#{count} #{'entry'.pluralize(count)} destroyed" }
    end
  end
end
