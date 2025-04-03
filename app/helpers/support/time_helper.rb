# frozen_string_literal: true

module Support
  module TimeHelper
    def gov_uk_format(time)
      time.strftime("%-l:%M%P on %-e %B %Y")
    end
  end
end
