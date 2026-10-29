# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindAndUseAnAPI::PublishCatalogueJob do
  it_behaves_like "a Solid Queue job", queue: "low_priority"

  it "publishes the catalogue entry when enabled" do
    allow(Settings.fauapi).to receive(:enabled).and_return(true)
    allow(FindAndUseAnAPI::PublishCatalogue).to receive(:call)

    described_class.perform_now

    expect(FindAndUseAnAPI::PublishCatalogue).to have_received(:call)
  end

  it "leaves the portal alone when disabled" do
    allow(Settings.fauapi).to receive(:enabled).and_return(false)
    allow(FindAndUseAnAPI::PublishCatalogue).to receive(:call)

    described_class.perform_now

    expect(FindAndUseAnAPI::PublishCatalogue).not_to have_received(:call)
  end

  context "when enabled" do
    before { allow(Settings.fauapi).to receive(:enabled).and_return(true) }

    it "tries a portal outage again later" do
      allow(FindAndUseAnAPI::PublishCatalogue).to receive(:call).and_raise(Faraday::ServerError)

      expect { described_class.perform_now }.to have_enqueued_job(described_class)
    end

    [
      FindAndUseAnAPI::Client::Rejected,
      FindAndUseAnAPI::PublishCatalogue::Error,
    ].each do |error_class|
      it "fails a #{error_class} without retrying" do
        allow(FindAndUseAnAPI::PublishCatalogue).to receive(:call).and_raise(error_class)

        expect { described_class.perform_now }.to raise_error(error_class)
        expect(described_class).not_to have_been_enqueued
      end
    end
  end
end
