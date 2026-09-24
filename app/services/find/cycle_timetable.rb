# frozen_string_literal: true

module Find
  class CycleTimetable
    CYCLE_DATES = {
      2021 => {
        find_opens: Time.zone.local(2020, 10, 6, 9),
        apply_opens: Time.zone.local(2020, 10, 13, 9),
        first_deadline_banner: Time.zone.local(2021, 7, 12, 9),
        apply_1_deadline: Time.zone.local(2021, 9, 7, 18),
        apply_deadline: Time.zone.local(2021, 9, 21, 18),
        find_closes: Time.zone.local(2021, 10, 4).end_of_day,
      },
      2022 => {
        find_opens: Time.zone.local(2021, 10, 5, 9),
        apply_opens: Time.zone.local(2021, 10, 12, 9),
        first_deadline_banner: Time.zone.local(2022, 8, 2, 9),
        apply_1_deadline: Time.zone.local(2022, 9, 6, 18),
        apply_deadline: Time.zone.local(2022, 9, 20, 18),
        find_closes: Time.zone.local(2022, 10, 3).end_of_day,
      },
      2023 => {
        find_opens: Time.zone.local(2022, 10, 4, 9),
        apply_opens: Time.zone.local(2022, 10, 11, 9),
        first_deadline_banner: Time.zone.local(2023, 8, 1, 9),
        apply_1_deadline: Time.zone.local(2023, 9, 5, 18),
        apply_deadline: Time.zone.local(2023, 9, 19, 18),
        find_closes: Time.zone.local(2023, 10, 2).end_of_day,
      },
      2024 => {
        find_opens: Time.zone.local(2023, 10, 3, 9),
        apply_opens: Time.zone.local(2023, 10, 10, 9),
        first_deadline_banner: Time.zone.local(2024, 7, 30, 9),
        apply_deadline: Time.zone.local(2024, 9, 17, 18),
        find_closes: Time.zone.local(2024, 9, 30).end_of_day,
      },
      2025 => {
        find_opens: Time.zone.local(2024, 10, 1, 9),
        apply_opens: Time.zone.local(2024, 10, 8, 9),
        first_deadline_banner: Time.zone.local(2025, 7, 12, 9),
        apply_deadline: Time.zone.local(2025, 9, 16, 18),
        find_closes: Time.zone.local(2025, 9, 29).end_of_day,
      },
      2026 => {
        find_opens: Time.zone.local(2025, 9, 30, 9),
        apply_opens: Time.zone.local(2025, 10, 7, 9),
        first_deadline_banner: Time.zone.local(2026, 7, 12, 9),
        apply_deadline: Time.zone.local(2026, 9, 15, 18),
        find_closes: Time.zone.local(2026, 9, 28).end_of_day,
      },
      2027 => {
        find_opens: Time.zone.local(2026, 9, 29, 9),
        apply_opens: Time.zone.local(2026, 10, 6, 9),
        first_deadline_banner: Time.zone.local(2027, 7, 12, 9),
        apply_deadline: Time.zone.local(2027, 9, 21, 18),
        find_closes: Time.zone.local(2027, 10, 4).end_of_day,
      },
      2028 => {
        find_opens: Time.zone.local(2027, 10, 5, 9),
        apply_opens: Time.zone.local(2027, 10, 12, 9),
        first_deadline_banner: Time.zone.local(2028, 7, 12, 9),
        apply_deadline: Time.zone.local(2028, 9, 19, 18),
        find_closes: Time.zone.local(2028, 10, 2).end_of_day,
      },
      2029 => {
        find_opens: Time.zone.local(2028, 10, 3, 9),
        apply_opens: Time.zone.local(2028, 10, 10, 9),
        first_deadline_banner: Time.zone.local(2029, 7, 12, 9),
        apply_deadline: Time.zone.local(2029, 9, 18, 18),
        find_closes: Time.zone.local(2029, 10, 1).end_of_day,
      },
    }.freeze

    # Every recruitment cycle phase, with the boundaries it runs between.
    # Everything else about a phase is derived from this table.
    #
    # A phase is a span where what a person can do differs. Find is up or down;
    # Apply takes a submission or does not. A span where only the wording on the
    # page changes is not a phase, which is why the deadline banner is a window
    # inside `apply_open` rather than a row here.
    #
    # The four rows tile the cycle end to end, and `phases_in_time` reads each
    # range as half-open, so the instant two rows share belongs to the row it
    # opens and never to both.
    #
    # They run in the order a cycle runs, starting from Apply closing.
    #
    # Nothing here knows about the cycle switcher. Which cycle year an option
    # loads is the switcher's business, and lives in SWITCHER_OPTIONS.
    PHASES = {
      # Closed, not merely shut to submissions: a candidate cannot create an
      # application either. That is what separates it from `apply_not_open_yet`,
      # where an application can be built but not sent. Find stays up throughout.
      apply_closed: {
        from: ->(year) { apply_deadline(year) },
        to: ->(year) { find_closes(year) },
      },
      # The only row that spans two cycle entries, because Find closing and Find
      # reopening are the seam between them. Indexed by the cycle it leads into,
      # which is where `cycle_year_for_time` puts all but a sliver of it.
      find_closed: {
        from: ->(year) { previous_find_closes(year) },
        to: ->(year) { find_opens(year) },
      },
      apply_not_open_yet: {
        from: ->(year) { find_opens(year) },
        to: ->(year) { apply_opens(year) },
      },
      apply_open: {
        from: ->(year) { apply_opens(year) },
        to: ->(year) { apply_deadline(year) },
      },
    }.freeze

    # What the cycle switcher offers, in the order it lists them. An option is a
    # phase plus the cycle it loads, so two options can name the same phase:
    # `apply_open` is Apply open in the cycle running now, `apply_reopened` is
    # Apply open in the cycle after the rollover.
    #
    # The walk is this cycle finishing, then the next one starting, so the
    # divider falls where `advances_cycle` first turns true.
    SWITCHER_OPTIONS = {
      apply_open: { phase: :apply_open, advances_cycle: false },
      apply_closed: { phase: :apply_closed, advances_cycle: false },
      find_closed: { phase: :find_closed, advances_cycle: true },
      apply_not_open_yet: { phase: :apply_not_open_yet, advances_cycle: true },
      apply_reopened: { phase: :apply_open, advances_cycle: true },
    }.freeze

    def self.current_year
      now = Time.zone.now
      current_year = cycle_year_for_time(now)

      # If the cycle switcher has been set to an option past the rollover then
      # we want to request next year's courses from the TTAPI
      if SWITCHER_OPTIONS.dig(current_cycle_schedule, :advances_cycle)
        current_year + 1
      else
        current_year
      end
    end

    # Returns the recruitment cycle year for a given time
    #
    # Recruitment Cycles run from the start of the day that find opens
    # to the moment find closes (end of day)
    # Error is raised if a time does not match a listed cycle
    def self.cycle_year_for_time(time)
      CYCLE_DATES.each do |year, dates|
        end_time = CYCLE_DATES[year + 1]&.dig(:find_opens)&.beginning_of_day || dates[:find_closes]&.end_of_day

        return year if time >= dates[:find_opens]&.beginning_of_day && time < end_time
      end

      raise "NoRecruitmentCycleExists: time #{time.to_fs(:db)}"
    end

    # Return the cycle year of last cycle if it's less than 30 days ago
    # Otherwise return nil
    #
    # @returns [year|nil]
    def self.years_available_to_support
      last_year = cycle_year_for_time(30.days.ago)
      last_year if current_year != last_year
    end

    def self.next_year
      current_year + 1
    end

    def self.previous_year
      current_year - 1
    end

    # Whether a cycle year is the current one or the one before it, as opposed
    # to a future cycle. Callers use this to branch on how a cycle behaves —
    # Publish, for one, picks its course status vocabulary from it.
    def self.current_or_previous_year?(year)
      [current_year, previous_year].include?(year.to_i)
    end

    def self.find_closes(year = current_year)
      date(:find_closes, year)
    end

    # When Find last shut before this cycle. The earliest cycle in the table has
    # nothing before it, so its closure starts where the table's knowledge starts.
    def self.previous_find_closes(year)
      return find_opens(year).beginning_of_day unless CYCLE_DATES.key?(year - 1)

      find_closes(year - 1)
    end

    def self.first_deadline_banner(year = current_year) = date(:first_deadline_banner, year)

    def self.apply_deadline(year = current_year)
      date(:apply_deadline, year)
    end

    def self.find_opens(year = current_year)
      date(:find_opens, year)
    end

    def self.find_reopens
      date(:find_opens, next_year)
    end

    # Next date find opens (either this cycle or next)
    # return nil if no date is found
    def self.next_find_opens
      cycle = CYCLE_DATES.values.find do |year|
        year[:find_opens] > Time.zone.now
      end

      return nil if cycle.blank?

      cycle[:find_opens]
    end

    def self.apply_opens(year = current_year)
      date(:apply_opens, year)
    end

    def self.apply_reopens
      date(:apply_opens, next_year)
    end

    # The stable open stage of the cycle: Apply is taking applications, Find is
    # up, no banner is showing and the cycle has settled.
    #
    # Anchored on `apply_opens` rather than `find_opens` so that lengthening the
    # pre-Apply week cannot swallow it. Two months rather than a few days because
    # the first 30 days after Find opens are the rollover grace window, where the
    # previous cycle is still served to support users.
    def self.mid_cycle(year = current_year)
      date(:apply_opens, year) + 2.months
    end

    def self.preview_mode?
      Time.zone.now.between?(apply_deadline, find_closes)
    end

    # One predicate per phase: the timetable's own vocabulary. Everything below
    # is expressed in terms of these rather than reaching for a phase key, so
    # each span has a single source of truth and callers keep a name that says
    # why they are asking.
    def self.find_closed? = phase_in_time?(:find_closed)
    def self.apply_not_open_yet? = phase_in_time?(:apply_not_open_yet)
    def self.apply_open? = phase_in_time?(:apply_open)
    def self.apply_closed? = phase_in_time?(:apply_closed)

    def self.find_open? = !find_closed?

    # Whether a candidate can create an application for the cycle on display.
    #
    # This spans two phases rather than reading one. Apply accepts a part built
    # application from the moment Find opens, a week before it accepts
    # submissions, so the apply button belongs on the page for both. The two
    # phases differ in whether Apply takes the finished application, but inside
    # Find only in what the page says about the wait.
    def self.can_create_application?
      apply_not_open_yet? || apply_open?
    end

    # The stable open stage: Apply is taking applications and no deadline banner
    # is up yet. Nothing in the app branches on this. It names the ordinary state
    # that `mid_cycle`, the instant, sits inside.
    def self.mid_cycle?
      apply_open? && !show_apply_deadline_banner?
    end

    # The deadline banner is a window inside `apply_open`, not a phase: nothing a
    # candidate can do changes when it appears. The switcher therefore toggles it
    # on its own rather than reaching it by picking a phase.
    def self.show_apply_deadline_banner?
      return false unless apply_open?
      return SiteSetting.deadline_banner? unless current_cycle_schedule == :real

      Time.zone.now.between?(first_deadline_banner, apply_deadline)
    end

    def self.apply_deadline_passed = apply_closed?

    def self.show_cycle_closed_banner? = apply_closed?

    def self.show_apply_opens_soon_banner? = apply_not_open_yet?

    def self.phase_range(phase, year)
      definition = PHASES.fetch(phase)
      [definition[:from].call(year), definition[:to].call(year)]
    end

    # The hints describe a fixed set of choices, so they read the real cycle year
    # rather than `current_year`, which advances for whichever option is selected
    # and would make the page describe itself.
    #
    # Returns the cycle the option loads, not the cycle the phase occurs in.
    def self.year_for_option(option, year = cycle_year_for_time(Time.zone.now))
      SWITCHER_OPTIONS.dig(option, :advances_cycle) ? year + 1 : year
    end

    def self.phase_for_option(option) = SWITCHER_OPTIONS.fetch(option).fetch(:phase)

    def self.option_range(option, year) = phase_range(phase_for_option(option), year)

    # One instant for every row, so the answers cannot disagree about the time.
    # Each range is half-open, which is what keeps the rows from overlapping at
    # the boundary they share.
    def self.phases_in_time
      year = current_year
      now = Time.zone.now

      PHASES.keys.index_with do |phase|
        from, to = phase_range(phase, year)
        from <= now && now < to
      end
    end

    # The phases tile the cycle and never overlap, so an option forced by the
    # switcher turns on its phase and nothing else. Only :real reads the clock,
    # and it is the only value that is not a switcher option, because
    # `current_cycle_schedule` reads anything else the switcher does not offer
    # as :real.
    #
    # Private, so a phase key never travels outside this class. Callers ask one
    # of the predicates above, which say why they are asking.
    def self.phase_in_time?(time_period)
      return phases_in_time[time_period] if current_cycle_schedule == :real

      SWITCHER_OPTIONS.dig(current_cycle_schedule, :phase) == time_period
    end
    private_class_method :phase_in_time?

    def self.date(name, year = current_year)
      real_schedule_for(year.to_i).fetch(name)
    end

    def self.cycle_year_range(year = current_year)
      "#{year} to #{year + 1}"
    end

    def self.next_cycle_year_range(year = current_year)
      "#{year + 1} to #{year + 2}"
    end

    def self.current_cycle_schedule
      # Make sure this setting only has effect on non-production environments
      return :real if Rails.env.production?

      schedule = SiteSetting.cycle_schedule

      # An option the switcher does not offer, such as one an earlier deploy
      # left in Redis, would match no phase and leave every predicate false.
      # Read it as the real cycle instead.
      return :real unless SWITCHER_OPTIONS.key?(schedule)

      schedule
    end

    def self.real_schedule_for(year = current_year)
      CYCLE_DATES[year]
    end
  end
end
