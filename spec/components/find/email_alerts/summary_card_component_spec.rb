# frozen_string_literal: true

require "rails_helper"

RSpec.describe Find::EmailAlerts::SummaryCardComponent, type: :component do
  let(:candidate) { create(:candidate) }

  describe "HTML escaping of user-controlled input" do
    context "when location_name contains HTML injection" do
      let(:email_alert) do
        create(
          :email_alert,
          candidate:,
          subjects: [],
          location_name: '<script>alert("xss")</script>',
          radius: 10,
        )
      end

      it "escapes HTML in filter row values" do
        rendered = render_inline(described_class.new(email_alert:))

        expect(rendered.to_html).not_to include("<script>")
        expect(rendered.text).to include('alert("xss")')
      end

      it "escapes HTML in the card title" do
        rendered = render_inline(described_class.new(email_alert:))

        expect(rendered.to_html).not_to include("<script>")
      end
    end

    context "when search_attributes provider_name contains HTML injection" do
      let(:email_alert) do
        create(
          :email_alert,
          candidate:,
          subjects: [],
          location_name: nil,
          radius: nil,
          search_attributes: { "provider_name" => '<img src=x onerror="alert(1)">' },
        )
      end

      it "escapes HTML in filter row values" do
        rendered = render_inline(described_class.new(email_alert:))

        expect(rendered.to_html).not_to include("<img src=x")
        expect(rendered.text).to include('onerror="alert(1)"')
      end
    end

    context "when location_name contains an excessively long string" do
      let(:email_alert) do
        create(
          :email_alert,
          candidate:,
          subjects: [],
          location_name: "A" * 5000,
          radius: 10,
        )
      end

      it "renders without error" do
        expect { render_inline(described_class.new(email_alert:)) }.not_to raise_error
      end
    end
  end
end
