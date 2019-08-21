module Courses
  class GenerateCourseCodeService
    def execute
      "#{valid_letters.sample}#{3.times.map { valid_number }.join}"
    end

  private

    def valid_letters
      ('A'..'Z').to_a - %w[O I]
    end

    def valid_number
      (0..9).to_a.sample.to_s
    end
  end
end
