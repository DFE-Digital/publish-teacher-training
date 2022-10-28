module FindInterface
  class LocationSubjectFilterComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :results

    def initialize(results:)
      super
      @results = results
    end

    def subjects_line
      to_sentence(@results.subjects.map { |subject| tag.b(subject[:subject_name]) }, last_word_connector: " and ")
    end
  end
end
