# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::AddProviderWizard::CheckAnswersPresenter do
  subject(:presenter) { described_class.new(wizard_on(:check_answers)) }

  let(:recruitment_cycle) { find_or_create(:recruitment_cycle) }
  let(:context) { { recruitment_cycle_year: recruitment_cycle.year } }
  let(:provider_details) do
    {
      provider_name: "Oak Academy",
      provider_code: "1AB",
      ukprn: "12345678",
      accredited: "1",
      accredited_provider_number: "5123",
      provider_type: "scitt",
    }
  end

  before do
    save(:provider_details, provider_details)
    save(:contact_details, email: "oak@example.com", telephone: "01632 960001", website: "https://oak.example.com", address1: "1 Oak Road", town: "Leeds", postcode: "LS1 1AA")
  end

  after { Rails.cache.clear }

  def wizard_on(step, params = {})
    Support::AddProviderWizard.new(
      state_key: "spec",
      context:,
      current_step: step,
      current_step_params: ActionController::Parameters.new(params),
    )
  end

  def save(step, attributes)
    expect(wizard_on(step, step => attributes).save_current_step).to be(true)
  end

  def rows_by_label(rows)
    rows.to_h { |row| [row.label, row.formatted_value] }
  end

  describe "#provider_rows" do
    it "shows the provider details of an accredited SCITT" do
      expect(rows_by_label(presenter.provider_rows)).to eq(
        "Provider name" => "Oak Academy",
        "Provider code" => "1AB",
        "UK provider reference number (UKPRN)" => "12345678",
        "Is the organisation an accredited provider?" => "Yes",
        "Accredited provider number" => "5123",
        "Provider type" => "School centred initial teacher training (SCITT)",
      )
    end

    context "when the provider is a lead school" do
      let(:provider_details) do
        super().merge(accredited: "0", accredited_provider_number: "", provider_type: "lead_school", urn: "123456")
      end

      it "shows the URN and not the accredited provider number" do
        expect(rows_by_label(presenter.provider_rows)).to include(
          "Is the organisation an accredited provider?" => "No",
          "Provider type" => "School",
          "Unique reference number (URN)" => "123456",
        )
        expect(rows_by_label(presenter.provider_rows)).not_to have_key("Accredited provider number")
      end
    end

    it "links each row to the provider details step with return_to_review" do
      expect(presenter.provider_rows.map(&:change_path).uniq).to contain_exactly(
        "/support/#{recruitment_cycle.year}/providers/onboarding/wizard/spec/provider_details?return_to_review=provider_details",
      )
    end
  end

  describe "#contact_rows" do
    it "shows the contact details" do
      expect(rows_by_label(presenter.contact_rows)).to eq(
        "Email address" => "oak@example.com",
        "Telephone number" => "01632 960001",
        "Website" => "https://oak.example.com",
        "Address" => "1 Oak Road<br> Leeds<br> LS1 1AA",
      )
    end
  end

  describe "#visually_hidden_text" do
    it "lower cases the first word of the label" do
      expect(presenter.visually_hidden_text(presenter.provider_rows.first)).to eq("provider name")
    end

    it "keeps an acronym at the start of the label" do
      expect(presenter.visually_hidden_text(presenter.provider_rows.third)).to eq("UK provider reference number (UKPRN)")
    end
  end
end
