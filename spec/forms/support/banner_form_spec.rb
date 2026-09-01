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
      "a day that does not exist in that month" => { "2i" => "2", "3i" => "30" },
      "a year containing a letter" => { "1i" => "2O26" },
    }.each do |description, published_at|
      it "rejects #{description} rather than raising or coercing" do
        subject = form(published_at:)

        expect(subject).not_to be_valid
        expect(subject.published_at).to be_nil
        expect(subject.errors[:published_at]).to contain_exactly("Enter a valid publish date and time")
      end
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
