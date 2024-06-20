# frozen_string_literal: true

module Find
  class CycleTimetable
    CYCLE_DATES = {
      2021 => {
        find_opens: Time.zone.local(2020, 10, 6, 9),
        apply_opens: Time.zone.local(2020, 10, 13, 9),
        first_deadline_banner: Time.zone.local(2021, 7, 12, 9),
        apply_1_deadline: Time.zone.local(2021, 9, 7, 18),
        apply_2_deadline: Time.zone.local(2021, 9, 21, 18),
        find_closes: Time.zone.local(2021, 10, 4, 23, 59, 59)
      },
      2022 => {
        find_opens: Time.zone.local(2021, 10, 5, 9),
        apply_opens: Time.zone.local(2021, 10, 12, 9),
        first_deadline_banner: Time.zone.local(2022, 8, 2, 9),
        apply_1_deadline: Time.zone.local(2022, 9, 6, 18),
        apply_2_deadline: Time.zone.local(2022, 9, 20, 18),
        find_closes: Time.zone.local(2022, 10, 3, 23, 59, 59)
      },
      2023 => {
        find_opens: Time.zone.local(2022, 10, 4, 9),
        apply_opens: Time.zone.local(2022, 10, 11, 9),

        first_deadline_banner: Time.zone.local(2023, 8, 1, 9), # 5 weeks before Apply 1 deadline
        apply_1_deadline: Time.zone.local(2023, 9, 5, 18), # First Tuesday of September
        apply_2_deadline: Time.zone.local(2023, 9, 19, 18), # 2 weeks after Apply 1 deadline
        find_closes: Time.zone.local(2023, 10, 2, 23, 59, 59) # The evening before Find opens in the new cycle
      },
      2024 => {
        find_opens: Time.zone.local(2023, 10, 3, 9), # First Tuesday of October
        apply_opens: Time.zone.local(2023, 10, 10, 9), # Second Tuesday of October
        first_deadline_banner: Time.zone.local(2024, 7, 30, 9), # 5 weeks before Apply 1 deadline
        apply_1_deadline: Time.zone.local(2024, 9, 3, 18), # First Tuesday of September
        apply_2_deadline: Time.zone.local(2024, 9, 17, 18), # 2 weeks after Apply 1 deadline
        find_closes: Time.zone.local(2024, 9, 30, 23, 59, 59) # The evening before Find opens in the new cycle
      },
      2025 => {
        find_opens: Time.zone.local(2024, 10, 1, 9),
        apply_opens: Time.zone.local(2024, 10, 8, 9),
        first_deadline_banner: Time.zone.local(2025, 7, 12, 9),
        apply_1_deadline: Time.zone.local(2025, 9, 7, 18),
        apply_2_deadline: Time.zone.local(2025, 9, 21, 18),
        find_closes: Time.zone.local(2025, 10, 4, 23, 59, 59)
      },
      2026 => {
        # NOTE: the dates from below here are not the finalised but are required
        # for the current implementation
        find_opens: Time.zone.local(2024, 10, 5, 9),
        apply_opens: Time.zone.local(2024, 10, 12, 9),
        first_deadline_banner: Time.zone.local(2025, 7, 12, 9),
        apply_1_deadline: Time.zone.local(2025, 9, 7, 18),
        apply_2_deadline: Time.zone.local(2025, 9, 21, 18),
        find_closes: Time.zone.local(2025, 10, 4, 23, 59, 59)
      }
    }.freeze

    def self.current_year
      now = Time.zone.now

      current_year = CYCLE_DATES.keys.detect do |year|
        return year if last_recruitment_cycle_year?(year)

        now.between?(CYCLE_DATES[year][:find_opens], CYCLE_DATES[year + 1][:find_opens])
      end

      # If the cycle switcher has been set to 'find has reopened' then
      # we want to request next year's courses from the TTAPI
      if SiteSetting.cycle_schedule == :today_is_after_find_opens
        current_year + 1
      else
        current_year
      end
    end

    def self.next_year
      current_year + 1
    end

    def self.previous_year
      current_year - 1
    end

    def self.find_closes
      date(:find_closes)
    end

    def self.first_deadline_banner
      date(:first_deadline_banner)
    end

    def self.apply_1_deadline
      date(:apply_1_deadline)
    end

    def self.apply_2_deadline
      date(:apply_2_deadline)
    end

    def self.find_opens
      date(:find_opens, current_year)
    end

    def self.find_reopens
      date(:find_opens, next_year)
    end

    def self.apply_reopens
      date(:apply_opens, next_year)
    end

    def self.mid_cycle
      date(:find_opens, current_year) + 1.day
    end

    def self.preview_mode?
      Time.zone.now.between?(apply_2_deadline, find_closes)
    end

    def self.find_down? = phase_in_time?(:today_is_after_find_closes)

    def self.mid_cycle? = phase_in_time?(:today_is_after_find_opens)

    def self.show_apply_1_deadline_banner? = phase_in_time?(:today_is_mid_cycle)

    def self.show_apply_2_deadline_banner? = phase_in_time?(:today_is_after_apply_1_deadline_passed)

    def self.show_cycle_closed_banner? = phase_in_time?(:today_is_after_apply_2_deadline_passed)

    def self.phases_in_time
      {
        today_is_after_find_closes: Time.zone.now.between?((find_closes.in_time_zone('London') - 1.hour), (find_reopens.in_time_zone('London') - 1.hour)),
        today_is_after_find_opens: Time.zone.now.between?((find_opens.in_time_zone('London') - 1.hour), apply_2_deadline),
        today_is_mid_cycle: Time.zone.now.between?(first_deadline_banner, apply_1_deadline),
        today_is_after_apply_1_deadline_passed: Time.zone.now.between?(apply_1_deadline, apply_2_deadline),
        today_is_after_apply_2_deadline_passed: Time.zone.now.between?(apply_2_deadline, find_closes)
      }
    end

    def self.phase_in_time?(time_period)
      if current_cycle_schedule == :real
        phases_in_time[time_period]
      else
        current_cycle_schedule == time_period
      end
    end

    def self.date(name, year = current_year)
      real_schedule_for(year).fetch(name)
    end

    def self.last_recruitment_cycle_year?(year)
      year == CYCLE_DATES.keys.last
    end

    def self.cycle_year_range(year = current_year)
      "#{year} to #{year + 1}"
    end

    def self.next_cycle_year_range(year = current_year)
      "#{year + 1} to #{year + 2}"
    end

    def self.current_cycle_schedule
      # Make sure this setting only has effect on non-production environments
      return :real if Rails.env.production_aks?

      SiteSetting.cycle_schedule
    end

    def self.real_schedule_for(year = current_year)
      CYCLE_DATES[year]
    end

    def self.fake_point_in_recruitment_cycle
      %i[
        today_is_mid_cycle
        today_is_after_apply_1_deadline_passed
        today_is_after_apply_2_deadline_passed
        today_is_after_find_closes
        today_is_after_find_opens
      ]
    end

    private_class_method :last_recruitment_cycle_year?
  end
end
