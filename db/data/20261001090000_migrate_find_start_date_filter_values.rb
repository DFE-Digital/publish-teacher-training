# frozen_string_literal: true

class MigrateFindStartDateFilterValues < ActiveRecord::Migration[8.1]
  # The Find start date filter replaced its broad options (jan_to_aug,
  # oct_to_jul) with narrower ones. Rewrites saved searches to the options that
  # replaced them, so their summaries and chips still render, and recomputes the
  # digest so they still match the same live search. updated_at is left alone
  # so recent searches keep their order.
  #
  # A candidate may already have an active alert for the replacement options;
  # the old alert is unsubscribed rather than duplicating it.
  def up
    [Candidate::EmailAlert, RecentSearch].each do |model|
      legacy_start_dates(model).find_each { |record| migrate(record) }
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def legacy_start_dates(model)
    model.where(
      "search_attributes->'start_date' ?| array[:values]",
      values: Courses::StartDateOptions::LEGACY.keys,
    )
  end

  def migrate(record)
    start_date = Courses::StartDateOptions.normalise(record.search_attributes["start_date"])
    record.search_attributes = record.search_attributes.merge("start_date" => start_date).compact_blank
    digest = record.compute_filter_key_digest

    if duplicate_active_alert?(record, digest)
      record.update_columns(search_attributes: record.search_attributes, filter_key_digest: digest, unsubscribed_at: Time.current)
    else
      record.update_columns(search_attributes: record.search_attributes, filter_key_digest: digest)
    end
  end

  def duplicate_active_alert?(record, digest)
    record.is_a?(Candidate::EmailAlert) &&
      record.unsubscribed_at.nil? &&
      Candidate::EmailAlert.active.where(candidate_id: record.candidate_id, filter_key_digest: digest).where.not(id: record.id).exists?
  end
end
