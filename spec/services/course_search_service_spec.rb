require "rails_helper"

describe CourseSearchService do
  describe ".call" do
    describe "when no scope is passed" do
      subject { described_class.call(filter: filter) }
      let(:filter) { {} }

      it "defaults to Course" do
        expect(Course).to receive(:findable).and_return(findable_scope)
        expect(subject).to eq(findable_scope)
      end
    end

    let(:scope) { class_double(Course) }
    let(:locatable_site_scope) { class_double(Course) }
    let(:findable_scope) { class_double(Course) }
    let(:filter) { nil }
    let(:sort) { nil }

    subject { described_class.call(filter: filter, sort: sort, course_scope: scope) }

    before do
      allow(scope).to receive(:with_locatable_site).and_return(locatable_site_scope)
      allow(locatable_site_scope).to receive(:findable).and_return(findable_scope)
    end

    describe "sort by" do
      let(:expected_scope) { double }

      context "ascending provider name and course name" do
        let(:sort) { "name,provider.provider_name" }

        it "orders in ascending order" do
          expect(findable_scope).to receive(:ascending_canonical_order).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "descending provider name and course name" do
        let(:sort) { "-provider.provider_name,-name" }

        it "orders in descending order" do
          expect(findable_scope).to receive(:descending_canonical_order).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "by distance" do
        let(:sort) { "distance" }
        let(:filter) do
          { latitude: 54.9713392, longitude: -1.6112336 }
        end

        it "orders in descending order" do
          expect(findable_scope).to receive(:by_distance).with(origin: [54.9713392, -1.6112336]).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "unspecified" do
        it "does not order" do
          expect(findable_scope).not_to receive(:order)
          expect(subject).not_to eq(expected_scope)
        end
      end
    end

    describe "filter is nil" do
      let(:filter) { nil }

      it "returns all" do
        expect(subject).to eq(findable_scope)
      end
    end

    describe "range" do
      context "when a range is specified" do
        let(:longitude) { 0 }
        let(:latitude) { 1 }
        let(:radius) { 5 }
        let(:filter) { { longitude: longitude, latitude: latitude, radius: radius } }
        let(:expected_scope) { double }

        it "adds the within scope" do
          expect(findable_scope).to receive(:within).with(radius, origin: [latitude, longitude]).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when a range is not specified" do
        let(:longitude) { 0 }
        let(:latitude) { 1 }
        let(:filter) { { longitude: longitude, latitude: latitude } }
        let(:expected_scope) { double }

        it "does not add the within scope" do
          expect(findable_scope).not_to receive(:within)
        end
      end
    end

    describe "filter[funding]" do
      context "when value is salary" do
        let(:filter) { { funding: "salary" } }
        let(:expected_scope) { double }

        it "adds the with_salary scope" do
          expect(findable_scope).to receive(:with_salary).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when value is all" do
        let(:filter) { { funding: "all" } }

        it "doesn't add the with_salary scope" do
          expect(findable_scope).not_to receive(:with_salary)
          expect(subject).to eq(findable_scope)
        end
      end
    end

    describe "filter[qualification]" do
      context "when qualifications passed" do
        let(:filter) { { qualification: "pgde,pgce_with_qts,pgde_with_qts,qts,pgce" } }
        let(:expected_scope) { double }

        it "adds the with_qualifications scope" do
          expect(findable_scope)
            .to receive(:with_qualifications)
            .with(%w(pgde pgce_with_qts pgde_with_qts qts pgce))
            .and_return(expected_scope)

          expect(subject).to eq(expected_scope)
        end
      end

      context "when no qualifications passed" do
        let(:filter) { {} }

        it "adds the with_qualifications scope" do
          expect(findable_scope)
            .not_to receive(:with_qualifications)

          expect(subject).to eq(findable_scope)
        end
      end
    end

    describe "filter[with_vacancies]" do
      context "when true" do
        let(:filter) { { has_vacancies: true } }
        let(:expected_scope) { double }

        it "adds the with_vacancies scope" do
          expect(findable_scope).to receive(:with_vacancies).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { has_vacancies: false } }

        it "adds the with_vacancies scope" do
          expect(findable_scope).not_to receive(:with_vacancies)
          expect(subject).to eq(findable_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the with_vacancies scope" do
          expect(findable_scope).not_to receive(:with_vacancies)
          expect(subject).to eq(findable_scope)
        end
      end
    end

    describe "filter[study_type]" do
      context "when full_time" do
        let(:filter) { { study_type: "full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(findable_scope).to receive(:with_study_modes).with(%w(full_time)).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when part_time" do
        let(:filter) { { study_type: "part_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(findable_scope).to receive(:with_study_modes).with(%w(part_time)).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when both" do
        let(:filter) { { study_type: "part_time,full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope with an array of both arguments" do
          expect(findable_scope).to receive(:with_study_modes).with(%w(part_time full_time)).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(findable_scope).not_to receive(:with_study_modes)
          expect(subject).to eq(findable_scope)
        end
      end
    end

    describe "filter[subjects]" do
      context "a single subject code" do
        let(:filter) { { subjects: "A1" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(findable_scope).to receive(:with_subjects).with(%w(A1)).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "multiple subject codes" do
        let(:filter) { { subjects: "A1,B2" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(findable_scope).to receive(:with_subjects).with(%w(A1 B2)).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(findable_scope).not_to receive(:with_subjects)
          expect(subject).to eq(findable_scope)
        end
      end
    end

    describe "filter[send_courses]" do
      context "when true" do
        let(:filter) { { send_courses: true } }
        let(:expected_scope) { double }

        it "adds the with_send scope" do
          expect(findable_scope).to receive(:with_send).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { send_courses: false } }

        it "adds the with_send scope" do
          expect(findable_scope).not_to receive(:with_send)
          expect(subject).to eq(findable_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the with_send scope" do
          expect(findable_scope).not_to receive(:with_send)
          expect(subject).to eq(findable_scope)
        end
      end
    end

    describe "multiple filters" do
      let(:filter) { { study_type: "part_time", funding: "salary" } }
      let(:salary_scope) { double }
      let(:expected_scope) { double }

      it "combines scopes" do
        expect(findable_scope).to receive(:with_salary).and_return(salary_scope)
        expect(salary_scope).to receive(:with_study_modes).with(%w(part_time)).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end
  end
end
