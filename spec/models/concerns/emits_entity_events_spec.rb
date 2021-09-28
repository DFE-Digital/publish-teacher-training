require "rails_helper"
require "sidekiq/testing"

# This spec is coupled to the Candidate model. I thought
# this was preferable to making an elaborate mock which
# didn't depend on the db
RSpec.describe EmitsEntityEvents do
  include ActiveJob::TestHelper
  let(:include_fields) { [] }

  before do
    allow(FeatureService).to receive(:enabled?).with(:send_request_data_to_bigquery).and_return(true)
    allow(Rails.configuration).to receive(:analytics).and_return({
      provider: include_fields,
    })
  end

  describe "create" do
    context "when an entity has configured fields to include" do
      let(:include_fields) { %w(provider_name provider_code) }

      before do
        create(:provider)
      end

      it "sends the event" do
        expect(SendEventToBigQueryJob).to have_been_enqueued
      end
    end

    context "when an entity does not have configured fields to include" do
      it "doesn't send an event" do
        expect(SendEventToBigQueryJob).not_to have_been_enqueued
      end
    end
  end

  describe "update" do
    before do
      provider = create(:provider)
      clear_enqueued_jobs
      provider.update(provider_name: "Dave", provider_code: "M1X")
    end

    context "when an entity has configured fields to include" do
      let(:include_fields) { %w(provider_name provider_code) }

      it "sends the event" do
        expect(SendEventToBigQueryJob).to have_been_enqueued
      end
    end

    context "when an entity does not have configured fields to include" do
      it "doesn't send an event" do
        expect(SendEventToBigQueryJob).not_to have_been_enqueued
      end
    end
  end

  describe "send_import_event" do
    let(:provider) { create(:provider) }

    before do
      provider
      clear_enqueued_jobs
    end

    it "sends an event" do
      provider.send_import_event
      expect(SendEventToBigQueryJob).to have_been_enqueued
    end

    it "sets the event type" do
      expect(provider.send_import_event.as_json["event_type"]).to eq("import_entity")
    end
  end
end
