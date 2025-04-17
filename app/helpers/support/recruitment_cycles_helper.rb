module Support
  module RecruitmentCyclesHelper
    def recruitment_cycle_status_tag(recruitment_cycle)
      options = {
        text: t("support.recruitment_cycles.index.status.#{recruitment_cycle.status}.text"),
        colour: recruitment_cycle_status_colour(recruitment_cycle),
      }

      govuk_tag(**options)
    end

    def recruitment_cycle_status_colour(recruitment_cycle)
      {
        current: "green",
        upcoming: "yellow",
        inactive: "grey",
      }[recruitment_cycle.status]
    end
  end
end
