require "rails_helper"

module Find
  describe SuggestedSearchLink do
    context "radius is nil" do
      subject { described_class.new(radius: nil, count: "5", parameters:) }

      let(:parameters) { { "lat" => "5", "lng" => "-5", "rad" => "10", "loc" => "Shetlands", "lq" => "2" } }

      describe "#text" do
        subject { super().text }

        it { is_expected.to eq("5 courses across England") }
      end

      describe "#suffix" do
        subject { super().suffix }

        it { is_expected.to eq("") }
      end

      describe "#url" do
        subject { super().url }

        it { is_expected.to eq("/find/results?l=2") }
      end
    end

    context "radius is 10" do
      subject(:suggested_search_link) { described_class.new(radius: "10", count: "5", parameters:) }

      let(:parameters) { { "lat" => "5", "lng" => "-5", "rad" => "5", "loc" => "Shetlands", "lq" => "2" } }

      describe "#text" do
        subject { super().text }

        it { is_expected.to eq("5 courses within 10 miles") }
      end

      describe "#suffix" do
        subject { super().suffix }

        it { is_expected.to eq("") }
      end

      describe "#url" do
        it "produces the correct URL" do
          uri = URI(suggested_search_link.url)
          expect(uri.path).to eq("/find/results")
          expect(Rack::Utils.parse_nested_query(uri.query)).to eq({
            "lat" => "5",
            "lng" => "-5",
            "rad" => "10",
            "loc" => "Shetlands",
            "lq" => "2",
          })
        end
      end
    end

    context "including_non_salaried is true" do
      subject { described_class.new(radius: nil, count: "5", parameters:, including_non_salaried: true) }

      let(:parameters) { { "lat" => "5", "lng" => "-5", "rad" => "10", "loc" => "Shetlands", "lq" => "2" } }

      describe "#text" do
        subject { super().text }

        it { is_expected.to eq("5 courses across England") }
      end

      describe "#suffix" do
        subject { super().suffix }

        it { is_expected.to eq(" - including both salaried courses and ones without a salary") }
      end
    end

    context "explicit_salary_filter is true" do
      let(:parameters) { { "lat" => "5", "lng" => "-5", "rad" => "10", "loc" => "Shetlands", "lq" => "2" } }

      describe "#text" do
        subject { described_class.new(radius: nil, count: "5", parameters:, explicit_salary_filter: true).text }

        it { is_expected.to eq("5 courses across England with a salary") }
      end

      describe "#suffix" do
        subject { described_class.new(radius: nil, count: "5", parameters:, explicit_salary_filter: true).suffix }

        it { is_expected.to eq("") }
      end
    end
  end
end
