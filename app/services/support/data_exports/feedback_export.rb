module Support
  module DataExports
    class FeedbackExport < Base
      def type
        "feedback"
      end

      def data
        Feedback.find_each.map { |feedback| feedback_data(feedback) }
      end

      def headers
        ["ID", "Ease of use", "User experience", "Created at"]
      end

      def to_csv
        CSV.generate(headers: true) do |csv|
          csv << headers
          data.each { |row| csv << row.values }
        end
      end

      def filename
        "feedbacks-#{Time.zone.now.strftime('%Y-%m-%d')}.csv"
      end

    private

      def feedback_data(feedback)
        {
          "ID" => feedback.id,
          "Ease of use" => feedback.ease_of_use,
          "User experience" => feedback.experience,
          "Created at" => feedback.created_at,
        }
      end
    end
  end
end
