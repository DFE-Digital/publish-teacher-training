# frozen_string_literal: true

class URNParser
  def initialize(urns)
    @urns = urns
  end

  def call
    processed = @urns.tr(',', "\n") # convert comma to newline
    processed = processed.tr("\t\r\s", '')
    processed.strip!.split("\n").compact_blank!
  end
end
