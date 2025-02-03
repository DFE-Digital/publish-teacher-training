module Find
  class LocationSuggestions
    attr_reader :input

    def initialize(input, suggestion_strategy:)
      @input = input
      @suggestion_strategy = suggestion_strategy
    end

    def call
      { suggestions: @suggestion_strategy.autocomplete(input) }
    end
  end
end

