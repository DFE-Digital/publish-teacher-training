module Support
  module RecruitmentCyclesHelper
    def recruitment_cycle_status_tag(recruitment_cycle)
      options = {
        text: t("support.recruitment_cycles.index.status.#{recruitment_cycle.status}.text"),
        colour: t("support.recruitment_cycles.index.status.#{recruitment_cycle.status}.colour"),
      }

      govuk_tag(**options)
    end
  end
end
