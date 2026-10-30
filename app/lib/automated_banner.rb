# frozen_string_literal: true

class AutomatedBanner
  DISPLAYED_ON = {
    rollover_started: [:publish],
    apply_opens_soon: [:find],
  }.freeze

  attr_reader :id, :published_at, :expired_at, :displayed_on

  def self.all(now = Time.current, interface: nil)
    DISPLAYED_ON
      .select { |_id, displayed_on| interface.nil? || displayed_on.include?(interface.to_sym) }
      .filter_map { |id, _displayed_on| send(id, now) }
  end

  def self.find(id)
    all.find { |banner| banner.id == id } || raise(ActiveRecord::RecordNotFound)
  end

  def self.scheduled(now = Time.current)
    all(now).select { |banner| banner.published_at > now }
  end

  def self.active(now = Time.current, interface: nil)
    all(now, interface:).select { |banner| banner.active?(now) }
  end

  def self.rollover_started(now)
    upcoming(now) do |year|
      next if Find::CycleTimetable.find_opens(year) < now

      available_in_publish_from = RecruitmentCycle.find_by(year:)&.available_in_publish_from
      next unless available_in_publish_from

      new(id: "rollover_started", year:, now:,
          published_at: available_in_publish_from.in_time_zone.beginning_of_day,
          expired_at: Find::CycleTimetable.find_opens(year))
    end
  end

  def self.apply_opens_soon(now)
    upcoming(now) do |year|
      published_at, expired_at = Find::CycleTimetable.phase_range(:apply_not_open_yet, year)

      new(id: "apply_opens_soon", year:, now:, published_at:, expired_at:)
    end
  end

  def self.upcoming(now, &block)
    year = Find::CycleTimetable.cycle_year_for_time(now)

    [year, year + 1]
      .select { |candidate| Find::CycleTimetable::CYCLE_DATES.key?(candidate) }
      .lazy
      .filter_map(&block)
      .find { |banner| banner.expired_at >= now }
  end
  private_class_method :rollover_started, :apply_opens_soon, :upcoming

  def initialize(id:, year:, now:, published_at:, expired_at:)
    @id = id
    @year = year
    @now = now
    @displayed_on = DISPLAYED_ON.fetch(id.to_sym)
    @published_at = published_at
    @expired_at = expired_at
  end

  def status = published_at > now ? :scheduled : :active

  def active?(at = now)
    return Find::CycleTimetable.show_apply_opens_soon_banner? if id == "apply_opens_soon"

    published_at <= at && expired_at >= at
  end

  def name = I18n.t("automated_banners.#{id}.name")

  def heading = I18n.t("automated_banners.#{id}.heading", **interpolations, default: nil)

  def body = I18n.t("automated_banners.#{id}.body", **interpolations)

private

  attr_reader :year, :now

  def interpolations
    {
      cycle_year_range: Find::CycleTimetable.cycle_year_range(year),
      find_opens: Find::CycleTimetable.find_opens(year).to_fs(:govuk_date),
      apply_opens: Find::CycleTimetable.apply_opens(year).to_fs(:govuk_date),
      count: (Find::CycleTimetable.apply_opens(year).to_date - [now, published_at].max.to_date).to_i,
    }
  end
end
