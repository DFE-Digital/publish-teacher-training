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
