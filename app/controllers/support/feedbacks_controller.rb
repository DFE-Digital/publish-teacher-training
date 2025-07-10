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
            flash[:alert] = "Unable to download feedback data. Error: #{e.message}"
            redirect_to support_feedback_index_path
          end
        end
      end
    end

    def show
      @feedback = Feedback.find(params[:id])
    end
  end
end
