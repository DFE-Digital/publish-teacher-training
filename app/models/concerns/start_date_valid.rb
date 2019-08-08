module StartDateValid
  extend ActiveSupport::Concern
  included do
    def start_date_valid?(recruitment_year, course)
      if valid_start_date_range(recruitment_year).cover?(course.start_date)
        true
      else
        course.errors.add :start_date, "#{start_date} is not in the #{recruitment_cycle.year} cycle"
      end
    end

    def valid_start_date_range(recruitment_year)
      DateTime.new(recruitment_year, 8, 1)..(DateTime.new(recruitment_year + 1, 7, 31))
    end
  end
end
