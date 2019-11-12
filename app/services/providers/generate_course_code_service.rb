module Providers
  class GenerateCourseCodeService
    def execute
      "#{valid_letters.sample}#{valid_number}"
    end

  private

    def valid_letters
      ("A".."Z").to_a - %w[O I]
    end

    def valid_number
      [*0..999].sample.to_s.rjust(3, "0")
    end
  end
end
