# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261001090000_migrate_find_start_date_filter_values")

describe MigrateFindStartDateFilterValues do
  def run_migration
    described_class.new.up
  end

  def digest_for(record)
    Find::FilterKeyDigest.digest(subjects: record.subjects, search_attributes: record.search_params)
  end

  describe "email alerts" do
    let!(:email_alert) do
      create(:email_alert, search_attributes: { "start_date" => %w[jan_to_aug september], "funding" => %w[fee] })
    end

    it "replaces the options the filter used to offer" do
      run_migration

      expect(email_alert.reload.search_attributes).to eq(
        "start_date" => %w[jan_to_mar apr_to_jun jul_to_aug september],
        "funding" => %w[fee],
      )
    end

    it "recomputes the filter key digest" do
      run_migration

      expect(email_alert.reload.filter_key_digest).to eq(digest_for(email_alert))
    end

    it "leaves updated_at alone" do
      expect { run_migration }.not_to(change { email_alert.reload.updated_at })
    end

    it "is idempotent" do
      run_migration
      expect { run_migration }.not_to(change { email_alert.reload.attributes })
    end

    context "when the candidate already has an active alert for the replacement options" do
      let!(:equivalent_alert) do
        create(
          :email_alert,
          candidate: email_alert.candidate,
          subjects: email_alert.subjects,
          search_attributes: { "start_date" => %w[jan_to_mar apr_to_jun jul_to_aug september], "funding" => %w[fee] },
        )
      end

      it "unsubscribes the old alert rather than duplicating the search" do
        run_migration

        expect(email_alert.reload.unsubscribed_at).to be_present
        expect(equivalent_alert.reload.unsubscribed_at).to be_nil
      end
    end
  end

  describe "recent searches" do
    let!(:recent_search) { create(:recent_search, search_attributes: { "start_date" => %w[oct_to_jul] }) }

    it "replaces the options the filter used to offer and recomputes the digest" do
      run_migration

      recent_search.reload
      expect(recent_search.search_attributes).to eq(
        "start_date" => %w[oct_to_dec next_jan_to_mar next_apr_to_jun next_jul],
      )
      expect(recent_search.filter_key_digest).to eq(digest_for(recent_search))
    end

    it "leaves updated_at alone, so the order of recent searches is kept" do
      expect { run_migration }.not_to(change { recent_search.reload.updated_at })
    end
  end

  context "when a search only has the current options" do
    let!(:email_alert) { create(:email_alert, search_attributes: { "start_date" => %w[september] }) }

    it "is left untouched" do
      expect { run_migration }.not_to(change { email_alert.reload.attributes })
    end
  end

  context "when a search has no start date" do
    let!(:recent_search) { create(:recent_search, search_attributes: { "funding" => %w[salary] }) }

    it "is left untouched" do
      expect { run_migration }.not_to(change { recent_search.reload.attributes })
    end
  end

  describe "#down" do
    it "is irreversible" do
      expect { described_class.new.down }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
