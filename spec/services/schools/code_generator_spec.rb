# frozen_string_literal: true

require "rails_helper"

describe Schools::CodeGenerator do
  let(:provider) { create(:provider) }

  def seed_site(code)
    create(:site, provider:, code:)
  end

  def seed_provider_school(site_code)
    create(:provider_school, provider:, site_code:)
  end

  describe "#call" do
    it "returns 'A' for a provider with no sites or schools" do
      expect(described_class.call(provider:)).to eq("A")
    end

    it "returns the first alphabetical code not yet used" do
      seed_site("A")

      expect(described_class.call(provider:)).to eq("B")
    end

    it "fills the lowest free slot, not sequentially after the highest" do
      seed_site("B")
      seed_site("C")

      expect(described_class.call(provider:)).to eq("A")
    end

    it "reads used codes from both legacy sites and new provider_schools" do
      seed_site("A")
      seed_provider_school("B")

      expect(described_class.call(provider:)).to eq("C")
    end

    it "treats the same code appearing in both tables as used-once" do
      seed_site("A")
      seed_provider_school("A")

      expect(described_class.call(provider:)).to eq("B")
    end

    it "moves into the numeric range after A-Z are used" do
      ("A".."Z").each { |c| seed_site(c) }

      expect(described_class.call(provider:)).to eq("0")
    end

    it "returns 'AA' once all single-char codes are exhausted" do
      (("A".."Z").to_a + ("0".."9").to_a).each { |c| seed_site(c) }

      expect(described_class.call(provider:)).to eq("AA")
    end

    it "never returns '-' even when it is the only single-char code missing from used set" do
      # seed everything BUT "-"; the legacy generator could pick "-" here, we must not
      (("A".."Z").to_a + ("0".."9").to_a).each { |c| seed_site(c) }

      expect(described_class.call(provider:)).not_to eq("-")
    end

    it "tolerates a seeded '-' main-site code in provider_school without letting it affect picks" do
      seed_provider_school("-")

      expect(described_class.call(provider:)).to eq("A")
    end

    it "returns the next sequential code after the highest multi-char in use" do
      (("A".."Z").to_a + ("0".."9").to_a).each { |c| seed_site(c) }
      seed_site("AA")
      seed_site("AB")

      expect(described_class.call(provider:)).to eq("AC")
    end

    it "wraps from 'AZ' to 'BA'" do
      (("A".."Z").to_a + ("0".."9").to_a).each { |c| seed_site(c) }
      seed_site("AZ")

      expect(described_class.call(provider:)).to eq("BA")
    end

    it "ignores codes used by other providers" do
      other = create(:provider)
      create(:site, provider: other, code: "A")

      expect(described_class.call(provider:)).to eq("A")
    end

    it "ignores nil and blank codes in the union" do
      # guard against rogue data; we can't seed nil/blank via the Site factory cleanly
      # because Site validations enforce presence, but we can stub .pluck to simulate
      allow(provider.sites).to receive(:pluck).with(:code).and_return([nil, "", "A"])
      allow(provider.schools).to receive(:pluck).with(:site_code).and_return([nil, "", "B"])

      expect(described_class.call(provider:)).to eq("C")
    end
  end
end
