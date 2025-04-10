# frozen_string_literal: true

class URNParser
  def initialize(urns)
    @urns = urns
  end

  def call
    processed = @urns.tr(",", "\n")
    processed = processed.tr("\t\r\s", "")
    processed.split("\n").compact_blank.uniq
  end
end
