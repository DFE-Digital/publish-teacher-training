# frozen_string_literal: true

class StripPunctuationService
  include ServicePattern

  def initialize(string: nil)
    @string = string
  end

  def call
    string&.gsub(/['’.“”"]/, '')&.gsub(/[^0-9A-Za-z\s]/, ' ')
  end

  private

  attr_reader :string
end
