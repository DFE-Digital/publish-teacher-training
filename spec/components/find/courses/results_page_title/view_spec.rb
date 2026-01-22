require "rails_helper"

RSpec.describe Find::Courses::ResultsPageTitle::View, type: :component do
  subject(:result) do
    render_inline(
      described_class.new(
        courses_count:,
        address:,
        subjects:,
        radius:,
      ),
    ).text.strip
  end

  let(:subjects) { [] }
  let(:radius) { nil }

  describe "no location, no subject" do
    let(:address) { Geolocation::Address.new(formatted_address: nil) }

    context "when no results" do
      let(:courses_count) { 0 }

      it "renders no results message" do
        expect(result).to eq("No courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "renders page title without location" do
        expect(result).to eq("1 course found")
      end
    end

    context "when many results" do
      let(:courses_count) { 10 }

      it "renders page title without location" do
        expect(result).to eq("10 courses found")
      end
    end

    context "when large number of results" do
      let(:courses_count) { 1_000 }

      it "formats count with delimiter" do
        expect(result).to eq("1,000 courses found")
      end
    end
  end

  describe "no location, 1 subject entered" do
    let(:address) { Geolocation::Address.new(formatted_address: nil) }
    let(:subjects) { %w[F3] }
    let(:radius) { nil }

    context "when no results" do
      let(:courses_count) { 0 }

      it "renders no results message" do
        expect(result).to eq("No courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "renders page title with subject" do
        expect(result).to eq("1 physics course")
      end
    end

    context "when language subjects" do
      it "render subject name capital" do
        {
          "Q3" => "English",
          "A1" => "Ancient Greek",
          "A2" => "Ancient Hebrew",
          "15" => "French",
          "18" => "Italian",
          "19" => "Japanese",
          "A0" => "Latin",
          "20" => "Mandarin",
          "21" => "Russian",
          "22" => "Spanish",
          "17" => "German",
        }.each do |subject_code, subject_name|
          result = render_inline(
            described_class.new(
              courses_count: 10,
              address:,
              subjects: [subject_code],
              radius: nil,
            ),
          ).text.strip

          expect(result).to eq("10 #{subject_name} courses")
        end
      end
    end

    context "when many results" do
      let(:courses_count) { 10 }

      it "renders page title with subject" do
        expect(result).to eq("10 physics courses")
      end
    end

    context "when large number of results" do
      let(:courses_count) { 500 }

      it "formats count with delimiter and includes subject" do
        expect(result).to eq("500 physics courses")
      end
    end
  end

  describe "no location, 2+ subjects entered" do
    let(:address) { Geolocation::Address.new(formatted_address: nil) }
    let(:subjects) { %w[F3 I1] }

    context "when many results" do
      let(:courses_count) { 25 }

      it "reverts to default title" do
        expect(result).to eq("25 courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "reverts to default title" do
        expect(result).to eq("1 course found")
      end
    end
  end

  describe "simple location search (city/town/county/region), no subject" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "London, UK",
        locality: "London",
        postal_code: nil,
        route: nil,
      )
    end

    context "when no results" do
      let(:courses_count) { 0 }

      it "renders no results message" do
        expect(result).to eq("No courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "renders page title with location" do
        expect(result).to eq("1 course in London")
      end
    end

    context "when many results" do
      let(:courses_count) { 10 }

      it "renders page title with location" do
        expect(result).to eq("10 courses in London")
      end
    end

    context "when large number of results" do
      let(:courses_count) { 5_000 }

      it "formats count with delimiter" do
        expect(result).to eq("5,000 courses in London")
      end
    end
  end

  describe "county search, no subject" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "Hampshire, UK",
        administrative_area_level_4: "Hampshire",
        postal_code: nil,
        route: nil,
        locality: nil,
      )
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "renders page title with county" do
        expect(result).to eq("1 course in Hampshire")
      end
    end

    context "when many results" do
      let(:courses_count) { 25 }

      it "renders page title with county" do
        expect(result).to eq("25 courses in Hampshire")
      end
    end
  end

  describe "distance-based search (postcode + landmark), no subject" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "Piccadilly Circus, London, UK",
        route: "Piccadilly Circus",
        postal_code: "W1J 9HS",
        postal_town: "London",
        locality: "London",
      )
    end
    let(:radius) { 20 }

    context "when no results" do
      let(:courses_count) { 0 }

      it "renders no results message" do
        expect(result).to eq("No courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "renders page title with distance search and landmark" do
        expect(result).to include("1 course within 20 miles of")
        expect(result).to include("Piccadilly Circus")
      end
    end

    context "when many results" do
      let(:courses_count) { 10 }

      it "renders page title with distance search and landmark" do
        expect(result).to include("10 courses within 20 miles of")
        expect(result).to include("Piccadilly Circus")
      end
    end

    context "when large number of results" do
      let(:courses_count) { 2_500 }

      it "formats count with delimiter" do
        expect(result).to include("2,500 courses within 20 miles of")
      end
    end

    context "when search form radius is 10 miles" do
      let(:radius) { 10 }
      let(:courses_count) { 3 }

      it "renders page title with correct radius" do
        expect(result).to include("3 courses within 10 miles of")
      end
    end

    context "when search form radius is 100 miles" do
      let(:radius) { 100 }
      let(:courses_count) { 50 }

      it "renders page title with correct radius" do
        expect(result).to include("50 courses within 100 miles of")
      end
    end
  end

  describe "location and 1 subject entered (simple location)" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "London, UK",
        locality: "London",
        postal_code: nil,
        route: nil,
      )
    end
    let(:subjects) { %w[F3] }

    context "when no results" do
      let(:courses_count) { 0 }

      it "renders no results message" do
        expect(result).to eq("No courses found")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "renders page title with subject and location" do
        expect(result).to eq("1 physics course in London")
      end
    end

    context "when many results" do
      let(:courses_count) { 15 }

      it "renders page title with subject and location" do
        expect(result).to eq("15 physics courses in London")
      end
    end

    context "when large number of results" do
      let(:courses_count) { 1_200 }

      it "formats count with delimiter" do
        expect(result).to eq("1,200 physics courses in London")
      end
    end
  end

  describe "distance-based location and 1 subject entered" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "Piccadilly Circus, London, UK",
        route: "Piccadilly Circus",
        postal_code: "W1J 9HS",
        postal_town: "London",
        locality: "London",
      )
    end
    let(:subjects) { %w[G1] }
    let(:radius) { 15 }

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "renders page title with subject and distance" do
        expect(result).to include("1 mathematics course within 15 miles of")
        expect(result).to include("Piccadilly Circus")
      end
    end

    context "when many results" do
      let(:courses_count) { 8 }

      it "renders page title with subject and distance" do
        expect(result).to include("8 mathematics courses within 15 miles of")
        expect(result).to include("Piccadilly Circus")
      end
    end

    context "when large number of results" do
      let(:courses_count) { 3_500 }

      it "formats count with delimiter" do
        expect(result).to include("3,500 mathematics courses within 15 miles of")
      end
    end
  end

  describe "location and 2+ subjects entered" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "London, UK",
        locality: "London",
        postal_code: nil,
        route: nil,
      )
    end
    let(:subjects) { %w[F3 D3 C1] }

    context "when results exist" do
      let(:courses_count) { 30 }

      it "reverts to simple location title (ignores multiple subjects)" do
        expect(result).to eq("30 courses in London")
      end
    end

    context "when 1 result" do
      let(:courses_count) { 1 }

      it "reverts to simple location title" do
        expect(result).to eq("1 course in London")
      end
    end
  end

  describe "distance location and 2+ subjects entered" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "Piccadilly Circus, London, UK",
        route: "Piccadilly Circus",
        postal_code: "W1J 9HS",
        postal_town: "London",
        locality: "London",
      )
    end
    let(:subjects) { %w[F3 D3] }
    let(:radius) { 20 }

    context "when results exist" do
      let(:courses_count) { 20 }

      it "reverts to distance location title (ignores multiple subjects)" do
        expect(result).to include("20 courses within 20 miles of")
        expect(result).to include("Piccadilly Circus")
      end
    end
  end

  describe "edge cases" do
    context "when address is blank and search_form is nil" do
      let(:address) { Geolocation::Address.new }
      let(:courses_count) { 5 }

      it "renders page title without location" do
        expect(result).to eq("5 courses found")
      end
    end

    context "when subject is empty string in array" do
      let(:address) { Geolocation::Address.new(formatted_address: nil) }
      let(:subjects)  { [""] }
      let(:courses_count) { 5 }

      it "treats as no subject" do
        expect(result).to eq("5 courses found")
      end
    end

    context "when subject is nil in array" do
      let(:address) { Geolocation::Address.new(formatted_address: nil) }
      let(:subjects) { [nil, "F3"] }
      let(:courses_count) { 3 }

      it "treats as single subject (after compacting)" do
        expect(result).to eq("3 physics courses")
      end
    end

    context "when subject name is nil but has subjects in filtering" do
      let(:address) { Geolocation::Address.new(formatted_address: nil) }
      let(:subjects) { %w[F3] }
      let(:courses_count) { 3 }

      it "returns as single subject" do
        expect(result).to eq("3 physics courses")
      end
    end

    context "when search_form is nil but address has location" do
      let(:address) do
        Geolocation::Address.new(
          formatted_address: "London, UK",
          locality: "London",
        )
      end
      let(:courses_count) { 10 }

      it "renders with location and default values" do
        expect(result).to eq("10 courses in London")
      end
    end
  end

  describe "pluralization with subjects" do
    let(:address) { Geolocation::Address.new(formatted_address: nil) }
    let(:subjects) { %w[F3] }

    context "with 1 course" do
      let(:courses_count) { 1 }

      it "uses singular form" do
        expect(result).to eq("1 physics course")
      end
    end

    context "with 2 courses" do
      let(:courses_count) { 2 }

      it "uses plural form" do
        expect(result).to eq("2 physics courses")
      end
    end
  end

  describe "pluralization with subject and location" do
    let(:address) do
      Geolocation::Address.new(
        formatted_address: "London, UK",
        locality: "London",
      )
    end
    let(:subjects) { %w[F3] }

    context "with 1 course" do
      let(:courses_count) { 1 }

      it "uses singular form" do
        expect(result).to eq("1 physics course in London")
      end
    end

    context "with 2 courses" do
      let(:courses_count) { 2 }

      it "uses plural form" do
        expect(result).to eq("2 physics courses in London")
      end
    end
  end

  describe "security" do
    describe "SQL injection protection" do
      context "when subject code contains SQL injection attempt" do
        let(:address) { Geolocation::Address.new(formatted_address: nil) }
        let(:subjects) { ["F3' OR '1'='1"] }
        let(:courses_count) { 10 }

        it "rejects invalid subject code format" do
          expect(result).to eq("10 courses found")
        end
      end

      context "when subject code contains only special characters" do
        let(:address) { Geolocation::Address.new(formatted_address: nil) }
        let(:subjects) { ["'; DROP TABLE subjects; --"] }
        let(:courses_count) { 5 }

        it "rejects malicious subject code" do
          expect(Subject.count).to be > 0
          expect(result).to eq("5 courses found")
        end
      end

      context "when subject code is too long" do
        let(:address) { Geolocation::Address.new(formatted_address: nil) }
        let(:subjects) { ["F3#{'X' * 100}"] }
        let(:courses_count) { 7 }

        it "rejects subject code exceeding max length" do
          expect(result).to eq("7 courses found")
        end
      end

      context "when subject code contains lowercase letters" do
        let(:address) { Geolocation::Address.new(formatted_address: nil) }
        let(:subjects) { %w[f3] }
        let(:courses_count) { 8 }

        it "rejects invalid subject code format (lowercase)" do
          expect(result).to eq("8 courses found")
        end
      end
    end

    context "when subject contains HTML tags" do
      let(:address) { Geolocation::Address.new(formatted_address: nil) }
      let(:subjects) { ["<img src=x onerror=\"alert('xss')\">Physics</img>"] }
      let(:courses_count) { 5 }

      it "ignores subjects" do
        expect(result).to eq("5 courses found")
      end
    end

    context "when search_form.subjects is not an array" do
      let(:address) { Geolocation::Address.new(formatted_address: nil) }
      let(:subjects) { "F3" }
      let(:courses_count) { 6 }

      it "safely converts to array" do
        expect(result).to eq("6 physics courses")
      end
    end
  end
end
