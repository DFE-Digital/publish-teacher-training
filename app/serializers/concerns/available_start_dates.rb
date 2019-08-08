module AvailableStartDates
  extend ActiveSupport::Concern
  included do
    def start_dates(recruitment_year)
      dates = {
        august: "August #{recruitment_year}",
        september: "September #{recruitment_year}",
        october: "October #{recruitment_year}",
        november: "November #{recruitment_year}",
        decemember: "December #{recruitment_year}",
        january: "January #{recruitment_year}",
        february: "February #{recruitment_year}",
        march: "March #{recruitment_year}",
        april: "April #{recruitment_year}",
        may: "May #{recruitment_year}",
        june: "June #{recruitment_year}",
        july: "July #{recruitment_year}"
      }
      dates
    end
  end
end
