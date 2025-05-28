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

    def rollover_status(target_cycle:)
      colours = {
        in_progress: "yellow",
        finished: "green",
      }

      status = if target_cycle.upcoming?
                 :in_progress
               else
                 :finished
               end

      {
        text: t(".rollover_status.#{status}"),
        colour: colours[status],
      }
    end

    def rollover_summary(previous_target_cycle:, total_eligible_providers_count:, rolled_over_providers_count:, rollover_percentage:)
      return t(".rollover_status.no_previous_cycle") if previous_target_cycle.blank?

      t(
        ".rollover_status.summary",
        total_eligible_providers_count:,
        rolled_over_providers_count:,
        rollover_percentage:,
      )
    end
  end
end
