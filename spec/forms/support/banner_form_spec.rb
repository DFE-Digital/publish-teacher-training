# frozen_string_literal: true

require "rails_helper"

RSpec.describe Support::BannerForm, type: :model do
  def form(published_at: {}, expired_at: {})
    described_class.new(
      { "name" => "Banner", "body" => "Something has changed", "display_on_find" => "1" }
        .merge(parts("published_at", { "1i" => "2026", "2i" => "1", "3i" => "1", "4i" => "9", "5i" => "0" }.merge(published_at)))
        .merge(parts("expired_at", expired_at)),
    )
  end

  def parts(attribute, values)
    values.transform_keys { |part| "#{attribute}(#{part})" }
  end

  it "builds a time from complete date and time parts" do
    expect(form.published_at).to eq(Time.zone.local(2026, 1, 1, 9, 0))
  end

  describe "dates a support user can mistype" do
    {
      "a day beyond the month" => { "3i" => "32" },
      "a month beyond the year" => { "2i" => "13" },
      "a minute beyond the hour" => { "5i" => "60" },
      "an hour beyond the day" => { "4i" => "24" },
      "a day that does not exist in that month" => { "2i" => "2", "3i" => "30" },
      "a year containing a letter" => { "1i" => "2O26" },
      "a two-digit year" => { "1i" => "26" },
      "a five-digit year" => { "1i" => "12345" },
    }.each do |description, published_at|
      it "rejects #{description} rather than raising or coercing" do
        subject = form(published_at:)

        expect(subject).not_to be_valid
        expect(subject.published_at).not_to be_a(Time)
        expect(subject.errors[:published_at]).to contain_exactly("Enter a valid publish date and time")
      end
    end
  end

  it "ignores multiple parameter keys on an attribute that is not a date" do
    subject = described_class.new(
      { "name(1i)" => "2026", "name(2i)" => "1", "name(3i)" => "1", "body" => "Something has changed", "display_on_find" => "1" }
        .merge(parts("published_at", { "1i" => "2026", "2i" => "1", "3i" => "1", "4i" => "9", "5i" => "0" })),
    )

    expect(subject.name).to be_nil
  end

  describe "a date entered without a time" do
    it "starts the banner at the beginning of that day" do
      subject = form(published_at: { "4i" => "", "5i" => "" })

      expect(subject.published_at).to eq(Time.zone.local(2026, 1, 1))
    end

    it "expires the banner at the end of that day" do
      subject = form(expired_at: { "1i" => "2026", "2i" => "9", "3i" => "5", "4i" => "", "5i" => "" })

      expect(subject.expired_at).to eq(Time.zone.local(2026, 9, 5).end_of_day)
    end
  end

  describe "expiry" do
    it "is accepted when left entirely blank" do
      expect(form).to be_valid
    end

    it "is rejected when a time is given without a date" do
      subject = form(expired_at: { "4i" => "17", "5i" => "0" })

      expect(subject).not_to be_valid
      expect(subject.errors[:expired_at]).to contain_exactly("Enter a valid expiry date and time")
    end
  end
end
