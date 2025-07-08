module Support
  module DataExports
    class FeedbackExport < Base
      def type
        "feedback"
      end

      def data
        Feedback.find_each.map do |feedback|
          {
            "ID" => feedback.id,
            "Ease of use" => feedback.ease_of_use,
            "User experience" => feedback.experience,
            "Created at" => feedback.created_at,
          }
        end
      end

      def headers
        ["ID", "Ease of use", "User experience", "Created at"]
      end
    end
  end
end
