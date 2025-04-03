# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::SearchForm do
  describe "#search_params" do
    context "when can_sponsor_visa is true" do
      let(:form) { described_class.new(can_sponsor_visa: "true") }

      it "returns the correct search params with can_sponsor_visa set to true" do
        expect(form.search_params).to eq({ can_sponsor_visa: true })
      end
    end

    context "when send_courses is true" do
      let(:form) { described_class.new(send_courses: "true") }

      it "returns the correct search params with send_courses set to true" do
        expect(form.search_params).to eq({ send_courses: true })
      end
    end

    context "when applications_open is true" do
      let(:form) { described_class.new(applications_open: "true") }

      it "returns the correct search params with applications_open set to true" do
        expect(form.search_params).to eq({ applications_open: true })
      end
    end

    context "when study_types are provided" do
      let(:form) { described_class.new(study_types: %w[full_time part_time]) }

      it "returns the correct search params with study_types as an array" do
        expect(form.search_params).to eq({ study_types: %w[full_time part_time] })
      end
    end

    context "when study_types is an old parameter" do
      let(:form) { described_class.new(study_type: %w[full_time part_time]) }

      it "returns the correct search params with study_types as an array" do
        expect(form.search_params).to eq({ study_types: %w[full_time part_time] })
        expect(form.study_types).to eq(%w[full_time part_time])
      end
    end

    context "when further education is provided" do
      context "when new level params" do
        let(:form) { described_class.new(level: "further_education") }

        it "returns level search params" do
          expect(form.search_params).to eq({ level: "further_education" })
        end
      end

      context "when old age group params is used" do
        let(:form) { described_class.new(age_group: "further_education") }

        it "returns level search params" do
          expect(form.search_params).to eq({ level: "further_education" })
        end
      end

      context "when old qualification params is used as array" do
        let(:form) { described_class.new(qualification: ["pgce pgde"]) }

        it "returns level search params" do
          expect(form.search_params).to eq({ level: "further_education" })
        end
      end

      context "when all old qualification params is used" do
        let(:form) { described_class.new(qualification: ["qts", "pgce_with_qts", "pgce pgde"]) }

        it "returns level search params" do
          expect(form.search_params).to eq({ qualifications: %w[qts qts_with_pgce_or_pgde], level: "further_education" })
          expect(form.qualifications).to eq(%w[qts qts_with_pgce_or_pgde])
          expect(form.level).to eq("further_education")
        end
      end
    end

    context "when minimum degree grade is provided" do
      shared_examples "minimum degree required in search params" do |mapping|
        let(:form) { described_class.new(mapping[:from]) }

        it "maps #{mapping[:from]} to #{mapping[:to]}" do
          expect(form.search_params).to eq(mapping[:to])
        end

        it "returns the expected #{mapping[:to].keys.first} value" do
          expect(form.minimum_degree_required).to eq(mapping[:to].values.first)
        end
      end

      context "when new params" do
        include_examples "minimum degree required in search params",
                         from: { minimum_degree_required: "two_one" },
                         to: { minimum_degree_required: "two_one" }
      end

      context "when old 2:1 params is used" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "show_all_courses" },
                         to: { minimum_degree_required: "two_one" }
      end

      context "when old 2:2 params is used" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "two_two" },
                         to: { minimum_degree_required: "two_two" }
      end

      context 'when old "Third class" params is used' do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "third_class" },
                         to: { minimum_degree_required: "third_class" }
      end

      context 'when old "Pass" params is used' do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "not_required" },
                         to: { minimum_degree_required: "pass" }
      end

      context "when old undergraduate params is used" do
        include_examples "minimum degree required in search params",
                         from: { university_degree_status: false },
                         to: { minimum_degree_required: "no_degree_required" }
      end

      context "when old undergraduate params is used always takes precedence over degree required old param" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "show_all_courses", university_degree_status: false },
                         to: { minimum_degree_required: "no_degree_required" }
      end

      context "when param value does not exist" do
        include_examples "minimum degree required in search params",
                         from: { degree_required: "does_not_exist" },
                         to: {}
      end

      context "when show postgraduate params is used" do
        include_examples "minimum degree required in search params",
                         from: { university_degree_status: true },
                         to: {}
      end
    end

    context "when funding is provided" do
      let(:form) { described_class.new(funding: %w[fee salary]) }

      it "returns the correct search params with funding as an array" do
        expect(form.search_params).to eq({ funding: %w[fee salary] })
      end
    end

    context "when searching by provider" do
      context "when using the new parameter" do
        let(:form) { described_class.new(provider_name: "NIoT") }

        it "returns the correct search params with provider name" do
          expect(form.search_params).to eq({ provider_name: "NIoT" })
        end
      end

      context "when using the old parameter" do
        let(:form) { described_class.new('provider.provider_name': "NIoT") }

        it "returns the correct search params with provider name" do
          expect(form.search_params).to eq({ provider_name: "NIoT" })
        end
      end

      context "when searching by provider code" do
        let(:form) { described_class.new(provider_code: "ABC") }

        it "returns the correct search params with provider code" do
          expect(form.search_params).to eq({ provider_code: "ABC" })
        end
      end
    end

    context "when subjects are provided" do
      let(:form) { described_class.new(subjects: %w[C1]) }

      it "returns the correct search params with subjects" do
        expect(form.search_params).to eq({ subjects: %w[C1] })
      end
    end

    context "when subject code is provided" do
      let(:form) { described_class.new(subject_name: "Biology", subject_code: "C1") }

      it "convert into subjects and remove subject code" do
        expect(form.search_params).to eq({ subject_name: "Biology", subject_code: "C1" })
      end
    end

    context "when location is provided" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10) }

      it "returns the correct search params with location details" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10)
      end
    end

    context "when location is provided without radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435) }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10)
      end
    end

    context "when location is provided with blank radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: "") }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 10)
      end
    end

    context "when radius is provided without location" do
      let(:form) { described_class.new(radius: "10") }

      it "returns empty params" do
        expect(form.search_params).to eq({})
      end
    end

    context "when empty coordinates and subjects" do
      let(:form) { described_class.new(types: [], subject_code: "", subject_name: "") }

      it "returns empty search params" do
        expect(form.search_params).to eq({})
      end
    end

    context "when location is provided with radius" do
      let(:form) { described_class.new(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 200) }

      it "returns the correct search params with location details and default radius" do
        expect(form.search_params).to eq(location: "London NW9, UK", latitude: 51.53328, longitude: -0.1734435, radius: 200)
      end
    end

    context "when location is provided with administrative_area_level type and no radius" do
      let(:form) { described_class.new(location: "Cornwall, UK", latitude: 51.53328, longitude: -0.1734435, types: %w[administrative_area_level_2]) }

      it "returns the large area radius" do
        expect(form.search_params).to eq(location: "Cornwall, UK", latitude: 51.53328, longitude: -0.1734435, radius: 50, types: %w[administrative_area_level_2])
      end
    end

    context "when ordering is provided" do
      context "when new params" do
        let(:form) { described_class.new(order: "course_name_ascending") }

        it "returns the correct search params with order" do
          expect(form.search_params).to eq({ order: "course_name_ascending" })
        end
      end

      shared_examples "converts old ordering" do |mapping|
        let(:form) { described_class.new(mapping[:from]) }

        it "maps #{mapping[:from]} to #{mapping[:to]}" do
          expect(form.search_params).to eq(mapping[:to])
        end

        it "returns the expected #{mapping[:to].keys.first} value" do
          expect(form.order).to eq(mapping[:to].values.first)
        end
      end

      context "when using old course name ascending order params" do
        include_examples "converts old ordering", from: { sortby: "course_asc" }, to: { order: "course_name_ascending" }
      end

      context "when using old course name descending order params" do
        include_examples "converts old ordering", from: { sortby: "course_desc" }, to: { order: "course_name_descending" }
      end

      context "when using old provider name ascending order params" do
        include_examples "converts old ordering", from: { sortby: "provider_asc" }, to: { order: "provider_name_ascending" }
      end

      context "when using old provider name descending order params" do
        include_examples "converts old ordering", from: { sortby: "provider_desc" }, to: { order: "provider_name_descending" }
      end

      context "when using old order param with a non existent value" do
        include_examples "converts old ordering", from: { sortby: "something" }, to: {}
      end

      context "when using old order params with a non existent value and also using the new parameter" do
        include_examples "converts old ordering", from: { sortby: "something", order: "course_name_ascending" }, to: { order: "course_name_ascending" }
      end
    end

    context "when no attributes are set" do
      let(:form) { described_class.new }

      it "returns empty search params" do
        expect(form.search_params).to eq({})
      end
    end

    context "when multiple attributes are set" do
      let(:form) { described_class.new(can_sponsor_visa: "true", send_courses: "true", study_types: %w[full_time]) }

      it "returns the correct search params with all attributes" do
        expect(form.search_params).to eq({ can_sponsor_visa: true, send_courses: true, study_types: %w[full_time] })
      end
    end

    context "when attributes contain nil values" do
      let(:form) { described_class.new(can_sponsor_visa: nil) }

      it "returns search params without nil values" do
        expect(form.search_params).to eq({})
      end
    end
  end

  describe "#search_for_physics?" do
    context "when subjects include physics subject" do
      let(:form) { described_class.new(subjects: %w[F3]) }

      it "returns true" do
        expect(form.search_for_physics?).to be true
      end
    end

    context "when subjects include physics subject code" do
      let(:form) { described_class.new(subject_code: "F3") }

      it "returns true" do
        expect(form.search_for_physics?).to be true
      end
    end

    context "when engineers_teach_physics is present only without physics" do
      let(:form) { described_class.new(engineers_teach_physics: "true") }

      it "returns false" do
        expect(form.search_for_physics?).to be false
      end
    end

    context "when neither subjects include physics nor engineers_teach_physics is present" do
      let(:form) { described_class.new(subjects: %w[01]) }

      it "returns false" do
        expect(form.search_for_physics?).to be false
      end
    end
  end

  describe "#engineers_teach_physics" do
    context "when subjects include physics subject" do
      let(:form) { described_class.new(subjects: %w[F3], engineers_teach_physics: true) }

      it "returns true" do
        expect(form.engineers_teach_physics).to be true
      end
    end

    context "when subjects include physics subject code" do
      let(:form) { described_class.new(subject_code: "F3", engineers_teach_physics: true) }

      it "returns true" do
        expect(form.engineers_teach_physics).to be true
      end
    end

    context "when engineers_teach_physics is present only without physics" do
      let(:form) { described_class.new(engineers_teach_physics: true) }

      it "returns false" do
        expect(form.engineers_teach_physics).to be_nil
      end
    end

    context "when neither subjects include physics nor engineers_teach_physics is present" do
      let(:form) { described_class.new(subjects: %w[01]) }

      it "returns false" do
        expect(form.engineers_teach_physics).to be_nil
      end
    end
  end

  describe "#location" do
    context "when location is the old parameter" do
      let(:form) { described_class.new(lq: "London NW9, UK") }

      it "returns the correct search params with location details" do
        expect(form.location).to eq("London NW9, UK")
      end
    end

    context "when location is set" do
      let(:form) { described_class.new(location: "London NW9, UK") }

      it "returns the correct search params with location details" do
        expect(form.location).to eq("London NW9, UK")
      end
    end
  end
end
