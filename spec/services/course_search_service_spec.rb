# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseSearchService do
  describe ".call" do
    subject do
      described_class.call(filter:, sort:, course_scope: scope)
    end

    let(:course_with_includes) { class_double(Course) }
    let(:scope) { class_double(Course) }
    let(:select_scope) { class_double(Course) }
    let(:distinct_scope) { class_double(Course) }
    let(:course_ids_scope) { class_double(Course) }
    let(:order_scope) { class_double(Course) }
    let(:joins_provider_scope) { class_double(Course) }
    let(:inner_query_scope) { class_double(Course) }
    let(:outer_query_scope) { class_double(Course) }
    let(:filter) { nil }
    let(:sort) { nil }
    let(:expected_scope) { double }

    before do
      allow(Course).to receive(:includes)
        .with(
          :enrichments,
          :financial_incentives,
          course_subjects: [:subject],
          site_statuses: [:site],
          provider: %i[recruitment_cycle ucas_preferences],
        ).and_return(course_with_includes)

      allow(course_with_includes).to receive(:where).and_return(outer_query_scope)
      allow(scope).to receive(:with_degree_type).and_return(scope)
    end

    describe "when no scope is passed" do
      subject { described_class.call(filter:) }

      let(:filter) { {} }

      it "defaults to Course" do
        expect(course_with_includes).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    describe "sort by" do
      context "ascending provider name and course name" do
        let(:sort) { "provider.provider_name,name" }

        it "orders in ascending order" do
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).with(id: inner_query_scope).and_return(outer_query_scope)
          expect(outer_query_scope).to receive(:ascending_provider_canonical_order).and_return(select_scope)
          expect(select_scope).to receive(:select).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "descending provider name and course name" do
        let(:sort) { "-provider.provider_name,name" }

        it "orders in descending order" do
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(order_scope)
          expect(order_scope).to receive(:descending_provider_canonical_order).and_return(select_scope)
          expect(select_scope).to receive(:select).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "ascending course name and provider name" do
        let(:sort) { "name,provider.provider_name" }

        it "orders in ascending order" do
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).with(id: inner_query_scope).and_return(outer_query_scope)
          expect(outer_query_scope).to receive(:ascending_course_canonical_order).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "descending course name and provider name" do
        let(:sort) { "-name,provider.provider_name" }

        it "orders in descending order" do
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(order_scope)
          expect(order_scope).to receive(:descending_course_canonical_order).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "by distance" do
        let(:sort) { "distance" }

        describe "expand university" do
          context "when false" do
            let(:filter) do
              { latitude: 54.9713392, longitude: -1.6112336, expand_university: "false" }
            end

            it "orders in descending order by distance" do
              expect(scope).to receive(:select).and_return(inner_query_scope)
              expect(course_with_includes).to receive(:where).with(id: inner_query_scope).and_return(outer_query_scope)
              expect(outer_query_scope).to receive(:joins).and_return(joins_provider_scope)
              expect(joins_provider_scope).to receive(:joins).with(:provider).and_return(select_scope)
              distance_with_university_area_adjustment = <<~EOSQL.gsub(/\s+/m, " ").strip
                (CASE
                  WHEN provider.provider_type = 'O'
                    THEN (distance - 10)
                  ELSE distance
                END) as boosted_distance
              EOSQL
              select_criteria = "course.*, distance, #{distance_with_university_area_adjustment}"

              expect(select_scope).to receive(:select).with(select_criteria)
                                                      .and_return(order_scope)
              expect(order_scope).to receive(:order).with(:distance).and_return(expected_scope)
              expect(subject).to eq(expected_scope)
            end
          end

          context "when absent" do
            let(:filter) do
              { latitude: 54.9713392, longitude: -1.6112336 }
            end

            it "orders in descending order by distance" do
              expect(scope).to receive(:select).and_return(inner_query_scope)
              expect(course_with_includes).to receive(:where).with(id: inner_query_scope).and_return(outer_query_scope)
              expect(outer_query_scope).to receive(:joins).and_return(joins_provider_scope)
              expect(joins_provider_scope).to receive(:joins).with(:provider).and_return(select_scope)
              distance_with_university_area_adjustment = <<~EOSQL.gsub(/\s+/m, " ").strip
                (CASE
                  WHEN provider.provider_type = 'O'
                    THEN (distance - 10)
                  ELSE distance
                END) as boosted_distance
              EOSQL
              select_criteria = "course.*, distance, #{distance_with_university_area_adjustment}"

              expect(select_scope).to receive(:select).with(select_criteria)
                                                      .and_return(order_scope)
              expect(order_scope).to receive(:order).with(:distance).and_return(expected_scope)
              expect(subject).to eq(expected_scope)
            end
          end

          context "when true" do
            let(:filter) do
              { latitude: 54.9713392, longitude: -1.6112336, expand_university: "true" }
            end

            it "orders in descending order by boosted distance" do
              expect(scope).to receive(:select).and_return(inner_query_scope)
              expect(course_with_includes).to receive(:where).with(id: inner_query_scope).and_return(outer_query_scope)
              expect(outer_query_scope).to receive(:joins).and_return(joins_provider_scope)
              expect(joins_provider_scope).to receive(:joins).with(:provider).and_return(select_scope)
              distance_with_university_area_adjustment = <<~EOSQL.gsub(/\s+/m, " ").strip
                (CASE
                  WHEN provider.provider_type = 'O'
                    THEN (distance - 10)
                  ELSE distance
                END) as boosted_distance
              EOSQL
              select_criteria = "course.*, distance, #{distance_with_university_area_adjustment}"

              expect(select_scope).to receive(:select).with(select_criteria)
                                                      .and_return(order_scope)
              expect(order_scope).to receive(:order).with(:boosted_distance).and_return(expected_scope)
              expect(subject).to eq(expected_scope)
            end
          end
        end
      end

      context "unspecified" do
        it "does not order" do
          expect(scope).not_to receive(:order)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where)
          expect(subject).not_to eq(expected_scope)
        end
      end
    end

    describe "filter is nil" do
      let(:filter) { nil }

      it "returns all" do
        expect(scope).to receive(:select).and_return(inner_query_scope)
        expect(course_with_includes).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    describe "range" do
      context "when a range is specified" do
        let(:longitude) { 0 }
        let(:latitude) { 1 }
        let(:radius) { 5 }
        let(:filter) { { longitude:, latitude:, radius: } }

        it "adds the within scope" do
          expect(scope).to receive(:within).with(radius, origin: [latitude, longitude]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when a range is not specified" do
        let(:longitude) { 0 }
        let(:latitude) { 1 }
        let(:filter) { { longitude:, latitude: } }

        it "does not add the within scope" do
          expect(scope).not_to receive(:within)
        end
      end
    end

    describe "filter[provider.provider_name]" do
      context "when provider name is present" do
        let(:filter) { { 'provider.provider_name': "University of Warwick" } }
        let(:expected_scope) { double }
        let(:accredited_provider_scope) { double }
        let(:order_scope) { double }

        it "adds some scope" do
          expect(scope).to receive(:with_provider_name).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).with(:id).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(accredited_provider_scope)
          expect(accredited_provider_scope).to receive(:accredited_provider_order).and_return(order_scope)
          expect(order_scope).to receive(:ascending_provider_canonical_order).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[updated_since]" do
      let(:filter) { { updated_since: Time.zone.now.iso8601 } }
      let(:expected_scope) { double }

      it "adds the changed_since scope" do
        expect(scope).to receive(:changed_since).and_return(course_ids_scope)
        expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
        expect(course_with_includes).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    describe "filter[funding]" do
      context "when value is salary" do
        let(:filter) { { funding: "salary" } }
        let(:expected_scope) { double }

        it "adds the with_salary scope" do
          expect(scope).to receive(:with_salary).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when value is all" do
        let(:filter) { { funding: "all" } }

        it "doesn't add the with_salary scope" do
          expect(scope).not_to receive(:with_salary)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[qualification]" do
      context "when qualifications passed" do
        let(:filter) { { qualification: "pgde,pgce_with_qts,pgde_with_qts,qts,pgce" } }
        let(:expected_scope) { double }

        it "adds the with_qualifications scope" do
          expect(scope)
            .to receive(:with_qualifications)
            .with(%w[pgde pgce_with_qts pgde_with_qts qts pgce])
            .and_return(course_ids_scope)

          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)

          expect(subject).to eq(expected_scope)
        end
      end

      context "when no qualifications passed" do
        let(:filter) { {} }

        it "adds the with_qualifications scope" do
          expect(scope).not_to receive(:with_qualifications)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when qualification given as a hash" do
        let(:filter) { { qualification: { "0" => "qts", "1" => "pgce_with_qts", "2" => "pgce pgde" } } }
        let(:expected_scope) { double }

        it "adds the with_qualifications scope" do
          expect(scope)
            .to receive(:with_qualifications)
            .with(%w[qts pgce_with_qts pgce pgde pgde_with_qts])
            .and_return(course_ids_scope)

          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)

          expect(subject).to eq(expected_scope)
        end
      end

      context "when filter for undergraduate courses" do
        let(:filter) do
          {
            age_group: "secondary",
            visa_status: "false",
            university_degree_status: "false",
            qualification: "qts",
          }.with_indifferent_access
        end

        it "does add the with_qualifications scope" do
          expect(scope).not_to receive(:with_qualifications)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[findable]" do
      context "when true" do
        let(:filter) { { findable: true } }
        let(:expected_scope) { double }

        it "adds the findable scope" do
          expect(scope).to receive(:findable).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { findable: false } }

        it "doesn't add the findable scope" do
          expect(scope).not_to receive(:findable)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the findable scope" do
          expect(scope).not_to receive(:findable)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[study_type]" do
      context "when full_time" do
        let(:filter) { { study_type: "full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(scope).to receive(:with_study_modes).with(%w[full_time]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when part_time" do
        let(:filter) { { study_type: "part_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope" do
          expect(scope).to receive(:with_study_modes).with(%w[part_time]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when both" do
        let(:filter) { { study_type: "part_time,full_time" } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope with an array of both arguments" do
          expect(scope).to receive(:with_study_modes).with(%w[part_time full_time]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(scope).not_to receive(:with_study_modes)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when provided as a hash" do
        let(:filter) { { study_type: { "0" => "full_time", "1" => "part_time" } } }
        let(:expected_scope) { double }

        it "adds the with_study_modes scope with an array of both arguments" do
          expect(scope).to receive(:with_study_modes).with(%w[full_time part_time]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[funding_type]" do
      context "when fee" do
        let(:filter) { { funding_type: "fee" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w[fee]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when salary" do
        let(:filter) { { funding_type: "salary" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w[salary]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when apprenticeship" do
        let(:filter) { { funding_type: "apprenticeship" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w[apprenticeship]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when all" do
        let(:filter) { { funding_type: "fee,salary,apprenticeship" } }
        let(:expected_scope) { double }

        it "adds the with_funding_types scope" do
          expect(scope).to receive(:with_funding_types).with(%w[fee salary apprenticeship]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(scope).not_to receive(:with_funding_types)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[degree_grade]" do
      context "when two_two" do
        let(:filter) { { degree_grade: "two_two" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w[two_two]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when third_class" do
        let(:filter) { { degree_grade: "third_class" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w[third_class]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when not_required" do
        let(:filter) { { degree_grade: "not_required" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w[not_required]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when all" do
        let(:filter) { { degree_grade: "two_one,two_two,third_class,not_required" } }
        let(:expected_scope) { double }

        it "adds the with_degree_grades scope" do
          expect(scope).to receive(:with_degree_grades).with(%w[two_one two_two third_class not_required]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      describe "filter[degree_required]" do
        context "when two_two" do
          let(:filter) { { degree_required: "two_two" } }
          let(:expected_scope) { double }

          it "adds the with_degree_grades scope" do
            expect(scope).to receive(:with_degree_grades).with(%w[two_two third_class not_required]).and_return(course_ids_scope)
            expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
            expect(course_with_includes).to receive(:where).and_return(expected_scope)
            expect(subject).to eq(expected_scope)
          end
        end

        context "when third_class" do
          let(:filter) { { degree_required: "third_class" } }
          let(:expected_scope) { double }

          it "adds the with_degree_grades scope" do
            expect(scope).to receive(:with_degree_grades).with(%w[third_class not_required]).and_return(course_ids_scope)
            expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
            expect(course_with_includes).to receive(:where).and_return(expected_scope)
            expect(subject).to eq(expected_scope)
          end
        end

        context "when not_required" do
          let(:filter) { { degree_required: "not_required" } }
          let(:expected_scope) { double }

          it "adds the with_degree_grades scope" do
            expect(scope).to receive(:with_degree_grades).with(%w[not_required]).and_return(course_ids_scope)
            expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
            expect(course_with_includes).to receive(:where).and_return(expected_scope)
            expect(subject).to eq(expected_scope)
          end
        end

        context "when show_all_courses" do
          let(:filter) { { degree_required: "show_all_courses" } }
          let(:expected_scope) { double }

          it "adds the with_degree_grades scope" do
            expect(scope).to receive(:with_degree_grades).with(%w[two_one two_two third_class not_required]).and_return(course_ids_scope)
            expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
            expect(course_with_includes).to receive(:where).and_return(expected_scope)
            expect(subject).to eq(expected_scope)
          end
        end

        context "when absent" do
          let(:filter) { {} }

          it "doesn't add the scope" do
            expect(scope).not_to receive(:with_degree_grades)
            expect(scope).to receive(:select).and_return(inner_query_scope)
            expect(course_with_includes).to receive(:where).and_return(expected_scope)
            expect(subject).to eq(expected_scope)
          end
        end

        context "when not a string" do
          let(:filter) { { "hello" => "there" } }

          it "doesn't add the scope" do
            expect(scope).not_to receive(:with_degree_grades)
            expect(scope).to receive(:select).and_return(inner_query_scope)
            expect(course_with_includes).to receive(:where).and_return(expected_scope)
            expect(subject).to eq(expected_scope)
          end
        end

        context "when present but invalid value" do
          let(:filter) { { degree_required: "some_invalid_value" } }
          let(:expected_scope) { double }

          it "adds the with_degree_grades scope" do
            expect(scope).to receive(:with_degree_grades).with(%w[two_one two_two third_class not_required]).and_return(course_ids_scope)
            expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
            expect(course_with_includes).to receive(:where).and_return(expected_scope)
            expect(subject).to eq(expected_scope)
          end
        end
      end
    end

    describe "filter[subjects]" do
      context "a single subject code" do
        let(:filter) { { subjects: "A1" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(scope).to receive(:with_subjects).with(%w[A1]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "multiple subject codes" do
        let(:filter) { { subjects: "A1,B2" } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(scope).to receive(:with_subjects).with(%w[A1 B2]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the scope" do
          expect(scope).not_to receive(:with_subjects)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when not a string" do
        let(:filter) { { subjects: { "0" => "22", "1" => "W1", "2" => "C1" } } }
        let(:expected_scope) { double }

        it "adds the subject scope" do
          expect(scope).to receive(:with_subjects).with(%w[22 W1 C1]).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "filter[send_courses]" do
      context "when true" do
        let(:filter) { { send_courses: true } }
        let(:expected_scope) { double }

        it "adds the with_send scope" do
          expect(scope).to receive(:with_send).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { send_courses: false } }

        it "adds the with_send scope" do
          expect(scope).not_to receive(:with_send)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the with_send scope" do
          expect(scope).not_to receive(:with_send)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end

    describe "multiple filters" do
      let(:filter) { { study_type: "part_time", funding: "salary" } }
      let(:salary_scope) { double }
      let(:expected_scope) { double }

      it "combines scopes" do
        expect(scope).to receive(:with_salary).and_return(salary_scope)
        expect(salary_scope).to receive(:with_study_modes).with(%w[part_time]).and_return(course_ids_scope)
        expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
        expect(course_with_includes).to receive(:where).and_return(expected_scope)
        expect(subject).to eq(expected_scope)
      end
    end

    describe "filter[can_sponsor_visa]" do
      context "when true" do
        let(:filter) { { can_sponsor_visa: true } }
        let(:expected_scope) { double }

        it "adds the can_sponsor_visa scope" do
          expect(scope).to receive(:can_sponsor_visa).and_return(course_ids_scope)
          expect(course_ids_scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when false" do
        let(:filter) { { can_sponsor_visa: false } }

        it "adds the can_sponsor_visa scope" do
          expect(scope).not_to receive(:can_sponsor_visa)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end

      context "when absent" do
        let(:filter) { {} }

        it "doesn't add the can_sponsor_visa scope" do
          expect(scope).not_to receive(:can_sponsor_visa)
          expect(scope).to receive(:select).and_return(inner_query_scope)
          expect(course_with_includes).to receive(:where).and_return(expected_scope)
          expect(subject).to eq(expected_scope)
        end
      end
    end
  end

  describe "expand_university" do
    context "university course vs non university course" do
      null_island = { latitude: 0, longitude: 0 }

      over_5_miles_from_null_island = { latitude: 0.1, longitude: 0 }

      subject do
        described_class.call(filter:,
                             sort: "distance",
                             course_scope: scope)
      end

      let(:university_course) do
        create(:course, provider: university_provider,
                        site_statuses: [build(:site_status, :findable, site:)],
                        enrichments: [build(:course_enrichment, :published)])
      end
      let(:scope) do
        Course.all
      end

      let(:non_university_course) do
        create(:course, provider: non_university_provider,
                        site_statuses: [build(:site_status, :findable, site: site2)],
                        enrichments: [build(:course_enrichment, :published)])
      end

      let(:courses) do
        [university_course, non_university_course]
      end

      let(:site) do
        build(:site, **over_5_miles_from_null_island)
      end

      let(:site2) do
        build(:site, **null_island)
      end

      let(:university_provider) do
        build(:provider, provider_type: :university, sites: [site])
      end

      let(:non_university_provider) do
        build(:provider, provider_type: :scitt, sites: [site2])
      end

      before do
        courses
      end

      context "when false" do
        let(:filter) do
          null_island.merge(expand_university: "false")
        end

        it "returns correctly" do
          expect(subject.count(:id)).to eq(2)

          expect(subject.first.boosted_distance).to eq(0)
          expect(subject.first.distance).to eq(0)
          expect(subject.first).to eq(non_university_course)

          expect(subject.second.boosted_distance - subject.second.distance).to eq(-10)
          expect(subject.second).to eq(university_course)
        end
      end

      context "when absent" do
        let(:filter) do
          null_island
        end

        it "returns correctly" do
          expect(subject.count(:id)).to eq(2)

          expect(subject.first.boosted_distance).to eq(0)
          expect(subject.first.distance).to eq(0)
          expect(subject.first).to eq(non_university_course)

          expect(subject.second.boosted_distance - subject.second.distance).to eq(-10)
          expect(subject.second).to eq(university_course)
        end
      end

      context "when true" do
        describe "university course has less 10 miles" do
          let(:filter) do
            null_island.merge(expand_university: "true")
          end

          it "returns correctly" do
            expect(subject.count(:id)).to eq(2)

            expect(subject.first.boosted_distance - subject.first.distance).to eq(-10)
            expect(subject.first).to eq(university_course)

            expect(subject.second.boosted_distance).to eq(0)
            expect(subject.second.distance).to eq(0)
            expect(subject.second).to eq(non_university_course)
          end
        end
      end
    end
  end
end
