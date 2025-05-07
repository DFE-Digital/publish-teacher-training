# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do
  describe ".call" do
    subject(:results) { described_class.call(params:) }

    let(:test_search_result_wrapper_klass) do
      Class.new(SimpleDelegator) do
        attr_reader :minimum_distance_to_search_location

        def initialize(course, minimum_distance_to_search_location:)
          super(course)
          @minimum_distance_to_search_location = minimum_distance_to_search_location
        end
      end
    end

    context "when no filters or sorting are applied" do
      let!(:findable_course) { create(:course, :with_full_time_sites) }
      let!(:another_course) { create(:course, :with_full_time_sites) }
      let!(:non_findable_course) { create(:course) }

      let(:params) { {} }

      it "returns all findable courses" do
        expect(results).to contain_exactly(findable_course, another_course)
      end
    end

    context "when filter for visa sponsorship" do
      let!(:course_that_sponsor_visa) do
        create(:course, :with_full_time_sites, :can_sponsor_skilled_worker_visa, name: "Art and design")
      end
      let!(:another_course_that_sponsor_visa) do
        create(:course, :with_full_time_sites, :can_sponsor_student_visa, name: "Biology")
      end
      let!(:another_course_that_sponsor_all_visas) do
        create(:course, :with_full_time_sites, :can_sponsor_student_visa, :can_sponsor_skilled_worker_visa, name: "Computing")
      end
      let!(:course_that_does_not_sponsor_visa) do
        create(:course, :with_full_time_sites, can_sponsor_skilled_worker_visa: false, can_sponsor_student_visa: false, name: "Drama")
      end

      let(:params) { { can_sponsor_visa: "true" } }

      it "returns courses that sponsor visa" do
        expect(results).to match_collection(
          [course_that_sponsor_visa, another_course_that_sponsor_visa, another_course_that_sponsor_all_visas],
          attribute_names: %w[can_sponsor_skilled_worker_visa can_sponsor_student_visa],
        )
      end
    end

    context "when filter for engineers teach physics" do
      let!(:biology_course) do
        create(
          :course,
          :with_full_time_sites,
          :secondary,
          name: "Biology",
          course_code: "S872",
          subjects: [find_or_create(:secondary_subject, :biology)],
        )
      end
      let!(:physics_course) do
        create(
          :course,
          :with_full_time_sites,
          :secondary,
          name: "Physics",
          course_code: "P45D",
          subjects: [find_or_create(:secondary_subject, :physics)],
        )
      end
      let!(:engineers_teach_physics_course) do
        create(
          :course,
          :with_full_time_sites,
          :secondary,
          :engineers_teach_physics,
          name: "Engineers teach physics",
          course_code: "ETP1",
          subjects: [find_or_create(:secondary_subject, :physics)],
        )
      end

      let(:params) { { engineers_teach_physics: true } }

      it "returns courses that sponsor visa" do
        expect(results).to match_collection(
          [engineers_teach_physics_course],
          attribute_names: %w[id name campaign_name],
        )
      end
    end

    context "when filter by subject code" do
      let!(:biology) do
        create(:course, :with_full_time_sites, :secondary, name: "Biology", subjects: [find_or_create(:secondary_subject, :biology)])
      end
      let!(:chemistry) do
        create(:course, :with_full_time_sites, :secondary, name: "Chemistry", subjects: [find_or_create(:secondary_subject, :chemistry)])
      end
      let!(:mathematics) do
        create(:course, :with_full_time_sites, :secondary, name: "Mathematics", subjects: [find_or_create(:secondary_subject, :mathematics)])
      end

      let(:params) { { subject_code: "C1" } }

      it "returns courses that match the given subject code" do
        expect(results).to match_collection(
          [biology],
          attribute_names: %w[name],
        )
      end
    end

    context "when filter by subject code and subjects" do
      let!(:biology) do
        create(:course, :with_full_time_sites, :secondary, name: "Biology", subjects: [find_or_create(:secondary_subject, :biology)])
      end
      let!(:chemistry) do
        create(:course, :with_full_time_sites, :secondary, name: "Chemistry", subjects: [find_or_create(:secondary_subject, :chemistry)])
      end
      let!(:mathematics) do
        create(:course, :with_full_time_sites, :secondary, name: "Mathematics", subjects: [find_or_create(:secondary_subject, :mathematics)])
      end

      let(:params) { { subjects: %w[F1], subject_code: "C1" } }

      it "returns courses that match both the given subject code and subjects" do
        expect(results).to match_collection(
          [biology, chemistry],
          attribute_names: %w[name],
        )
      end
    end

    context "when filter by secondary subjects" do
      let!(:biology) do
        create(:course, :with_full_time_sites, :secondary, name: "Biology", subjects: [find_or_create(:secondary_subject, :biology)])
      end
      let!(:chemistry) do
        create(:course, :with_full_time_sites, :secondary, name: "Chemistry", subjects: [find_or_create(:secondary_subject, :chemistry)])
      end
      let!(:mathematics) do
        create(:course, :with_full_time_sites, :secondary, name: "Mathematics", subjects: [find_or_create(:secondary_subject, :mathematics)])
      end

      let(:params) { { subjects: %w[C1 F1] } }

      it "returns specific secondary courses" do
        expect(results).to match_collection(
          [biology, chemistry],
          attribute_names: %w[name],
        )
      end
    end

    context "when filter by study mode" do
      let!(:full_time_course) do
        create(:course, :with_full_time_sites, study_mode: "full_time", name: "Biology", course_code: "S872")
      end
      let!(:part_time_course) do
        create(:course, :with_part_time_sites, study_mode: "part_time", name: "Chemistry", course_code: "K592")
      end
      let!(:full_time_or_part_time_course) do
        create(:course, :with_full_time_or_part_time_sites, study_mode: "full_time_or_part_time", name: "Computing", course_code: "L364")
      end

      context "when filter by full time only" do
        let(:params) { { study_types: %w[full_time] } }

        it "returns full time courses only" do
          expect(results).to match_collection(
            [full_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode],
          )
        end
      end

      context "when filter by part time only" do
        let(:params) { { study_types: %w[part_time] } }

        it "returns part time courses only" do
          expect(results).to match_collection(
            [part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode],
          )
        end
      end

      context "when filter by full time and part time" do
        let(:params) { { study_types: %w[full_time part_time] } }

        it "returns full time and part time courses" do
          expect(results).to match_collection(
            [full_time_course, part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode],
          )
        end
      end

      context "when pass invalid parameter" do
        let(:params) { { study_types: "something" } }

        it "returns full time and part time courses" do
          expect(results).to match_collection(
            [full_time_course, part_time_course, full_time_or_part_time_course],
            attribute_names: %w[study_mode],
          )
        end
      end
    end

    context "when filter by qualifications" do
      let!(:qts_course) do
        create(:course, :with_full_time_sites, qualification: "qts", name: "Art and design")
      end
      let!(:pgce_with_qts_course) do
        create(:course, :with_full_time_sites, qualification: "pgce_with_qts", name: "Biology")
      end
      let!(:pgde_with_qts_course) do
        create(:course, :with_full_time_sites, qualification: "pgde_with_qts", name: "Computing")
      end
      let!(:course_without_qts) do
        create(:course, :with_full_time_sites, qualification: "undergraduate_degree_with_qts", name: "Drama")
      end

      context "when filter by qts" do
        let(:params) { { qualifications: %w[qts] } }

        it "returns courses with qts qualification only" do
          expect(results).to match_collection(
            [qts_course],
            attribute_names: %w[qualification],
          )
        end
      end

      context "when filter by qts with pgce or pgde" do
        let(:params) { { qualifications: %w[qts_with_pgce_or_pgde] } }

        it "returns courses with qts and pgce/pgde qualifications" do
          expect(results).to match_collection(
            [pgce_with_qts_course, pgde_with_qts_course],
            attribute_names: %w[qualification],
          )
        end
      end

      context "when filter by qts with pgce (for backwards compatibility)" do
        let(:params) { { qualifications: %w[qts_with_pgce] } }

        it "returns courses with qts and pgce/pgde qualifications" do
          expect(results).to match_collection(
            [pgce_with_qts_course, pgde_with_qts_course],
            attribute_names: %w[qualification],
          )
        end
      end
    end

    context "when filter for further education" do
      let!(:further_education_course) do
        create(:course, :with_full_time_sites, level: "further_education")
      end
      let!(:regular_course) do
        create(:course, :with_full_time_sites, level: "secondary")
      end
      let(:params) { { level: "further_education" } }

      it "returns courses for further education only" do
        expect(results).to match_collection(
          [further_education_course],
          attribute_names: %w[level],
        )
      end
    end

    context "when filter for applications open" do
      let!(:course_opened) do
        create(:course, :with_full_time_sites, :open)
      end
      let!(:course_closed) do
        create(:course, :with_full_time_sites, :closed)
      end
      let(:params) { { applications_open: "true" } }

      it "returns courses that sponsor visa" do
        expect(results).to match_collection(
          [course_opened],
          attribute_names: %w[application_status],
        )
      end
    end

    context "when filter for special education needs" do
      let!(:course_with_special_education_needs) do
        create(:course, :with_full_time_sites, :with_special_education_needs)
      end
      let!(:course_with_no_special_education_needs) do
        create(:course, :with_full_time_sites, is_send: false)
      end
      let(:params) { { send_courses: "true" } }

      it "returns courses that sponsor visa" do
        expect(results).to match_collection(
          [course_with_special_education_needs],
          attribute_names: %w[is_send],
        )
      end
    end

    context "when filter by degree grade requirements" do
      let!(:requires_two_one_course) do
        create(:course, :published_postgraduate, degree_grade: "two_one", name: "Art and design")
      end
      let!(:requires_two_two_course) do
        create(:course, :published_postgraduate, degree_grade: "two_two", name: "Biology")
      end
      let!(:requires_third_class_course) do
        create(:course, :published_postgraduate, degree_grade: "third_class", name: "Computing")
      end
      let!(:requires_pass_degree) do
        create(:course, :published_postgraduate, degree_grade: "not_required", name: "Drama")
      end
      let!(:undergraduate_does_not_require_degree_course) do
        create(:course, :published_teacher_degree_apprenticeship, degree_grade: "not_required", name: "Mathematics")
      end

      context "when filter by two_one" do
        let(:params) { { minimum_degree_required: "two_one" } }

        it "returns courses requiring two_one or lower" do
          expect(results).to match_collection(
            [requires_two_one_course, requires_two_two_course, requires_third_class_course, requires_pass_degree],
            attribute_names: %w[name degree_grade degree_type],
          )
        end
      end

      context "when filter by two_two" do
        let(:params) { { minimum_degree_required: "two_two" } }

        it "returns courses requiring two_two or lower" do
          expect(results).to match_collection(
            [requires_two_two_course, requires_third_class_course, requires_pass_degree],
            attribute_names: %w[name degree_grade degree_type],
          )
        end
      end

      context "when filter by third class" do
        let(:params) { { minimum_degree_required: "third_class" } }

        it "returns courses requiring a third class degree or lower" do
          expect(results).to match_collection(
            [requires_third_class_course, requires_pass_degree],
            attribute_names: %w[name degree_grade degree_type],
          )
        end
      end

      context "when filter by pass" do
        let(:params) { { minimum_degree_required: "pass" } }

        it "returns courses requiring a pass degree" do
          expect(results).to match_collection(
            [requires_pass_degree],
            attribute_names: %w[name degree_grade degree_type],
          )
        end
      end

      context "when filter by not requiring a degree" do
        let(:params) { { minimum_degree_required: "no_degree_required" } }

        it "returns courses that do not require a degree" do
          expect(results).to match_collection(
            [undergraduate_does_not_require_degree_course],
            attribute_names: %w[name degree_grade degree_type],
          )
        end
      end
    end

    context "when filter by funding" do
      let!(:fee_course) do
        create(:course, :with_full_time_sites, funding: "fee", name: "Art and design")
      end
      let!(:salaried_course) do
        create(:course, :with_full_time_sites, funding: "salary", name: "Biology")
      end
      let!(:apprenticeship_course) do
        create(:course, :with_full_time_sites, funding: "apprenticeship", name: "Computing")
      end

      context "when filter by fee" do
        let(:params) { { funding: %w[fee] } }

        it "returns courses with fees only" do
          expect(results).to match_collection(
            [fee_course],
            attribute_names: %w[funding],
          )
        end
      end

      context "when filter by salary" do
        let(:params) { { funding: %w[salary] } }

        it "returns courses with salary" do
          expect(results).to match_collection(
            [salaried_course],
            attribute_names: %w[funding],
          )
        end
      end

      context "when filter by apprenticeship" do
        let(:params) { { funding: %w[apprenticeship] } }

        it "returns courses with apprenticeship" do
          expect(results).to match_collection(
            [apprenticeship_course],
            attribute_names: %w[funding],
          )
        end
      end

      context "when filter by salary in the old search parameter" do
        let(:params) { { funding: "salary" } }

        it "returns courses with salary" do
          expect(results).to match_collection(
            [salaried_course],
            attribute_names: %w[funding],
          )
        end
      end

      context "when filter by two funding types" do
        let(:params) { { funding: %w[fee salary] } }

        it "returns courses with the expected funding types" do
          expect(results).to match_collection(
            [fee_course, salaried_course],
            attribute_names: %w[funding],
          )
        end
      end

      context "when filter by all funding types" do
        let(:params) { { funding: %w[fee salary apprenticeship] } }

        it "returns all courses" do
          expect(results).to match_collection(
            [fee_course, salaried_course, apprenticeship_course],
            attribute_names: %w[funding],
          )
        end
      end
    end

    context "when searching by provider" do
      let!(:warwick_provider) do
        create(:provider, provider_name: "Warwick University")
      end
      let!(:warwick_courses) do
        [
          create(:course, :with_full_time_sites, provider: warwick_provider, name: "Biology"),
          create(:course, :with_full_time_sites, provider: warwick_provider, name: "Computing"),
        ]
      end
      let!(:niot_provider) do
        create(:provider, provider_name: "NIoT")
      end
      let!(:niot_accredited_courses) do
        [
          create(:course, :with_full_time_sites, accredited_provider_code: niot_provider.provider_code, name: "Biology"),
          create(:course, :with_full_time_sites, accredited_provider_code: niot_provider.provider_code, name: "Computing"),
        ]
      end
      let!(:essex_provider) do
        create(:provider, provider_name: "Essex University")
      end
      let!(:essex_courses) do
        [
          create(:course, :with_full_time_sites, provider: essex_provider, name: "Biology"),
          create(:course, :with_full_time_sites, provider: essex_provider, name: "Computing"),
        ]
      end

      context "when searching by provider name for the self ratified provider" do
        let(:params) { { provider_name: "Essex University" } }

        it "returns offered courses by the provider" do
          expect(results).to match_collection(
            essex_courses,
            attribute_names: %w[id name provider_name],
          )
        end
      end

      context "when searching by provider code for the self ratified provider" do
        let(:params) { { provider_code: essex_provider.provider_code } }

        it "returns offered courses by the provider" do
          expect(results).to match_collection(
            essex_courses,
            attribute_names: %w[id name provider_name],
          )
        end
      end

      context "when searching by provider name for the accredited provider" do
        let(:params) { { provider_name: "NIoT" } }

        it "returns offered courses by the provider" do
          expect(results).to match_collection(
            niot_accredited_courses,
            attribute_names: %w[id name provider_name],
          )
        end
      end

      context "when searching by provider code for the accredited provider" do
        let(:params) { { provider_code: niot_provider.provider_code } }

        it "returns offered courses by the provider" do
          expect(results).to match_collection(
            niot_accredited_courses,
            attribute_names: %w[id name provider_name],
          )
        end
      end

      context "when no results when searching by provider name" do
        let(:params) { { provider_name: "University that does not exist" } }

        it "returns no courses" do
          expect(results).to match_collection(
            [],
            attribute_names: %w[id name provider_name],
          )
        end
      end

      context "when provider code from another cycle" do
        let!(:last_cycle) { create(:recruitment_cycle, :previous) }
        let!(:last_cycle_niot) do
          create(
            :provider,
            provider_code: niot_provider.provider_code,
            recruitment_cycle: last_cycle,
          )
        end
        let!(:last_cycle_niot_accredited_courses) do
          create_list(:course, 2, :with_full_time_sites, accredited_provider_code: last_cycle_niot.provider_code, provider: create(:provider, recruitment_cycle: last_cycle))
        end
        let!(:last_cycle_essex_provider) do
          create(:provider, provider_code: essex_provider.provider_code, recruitment_cycle: last_cycle)
        end
        let!(:last_cycle_essex_courses) do
          create_list(:course, 2, :with_full_time_sites, provider: last_cycle_essex_provider)
        end

        it "returns only accredited courses from current cycle" do
          expect(
            described_class.call(
              params: { provider_code: last_cycle_niot.provider_code },
            ),
          ).to match_collection(
            niot_accredited_courses,
            attribute_names: %w[id name provider_name recruitment_cycle],
          )
        end

        it "returns only courses from current cycle" do
          expect(
            described_class.call(
              params: { provider_code: last_cycle_essex_provider.provider_code },
            ),
          ).to match_collection(
            essex_courses,
            attribute_names: %w[id name provider_name recruitment_cycle],
          )
        end
      end
    end

    shared_examples "location search results" do |radius:|
      it "returns courses within a #{radius} mile radius" do
        params = { latitude: london.latitude, longitude: london.longitude, radius: }

        expect(described_class.call(params:)).to match_collection(
          expected,
          attribute_names: %w[name minimum_distance_to_search_location],
        )
      end
    end

    context "when searching by location applying radius filter" do
      let(:london) { build(:location, :london) }
      let(:canary_wharf) { build(:location, :canary_wharf) }
      let(:lewisham) { build(:location, :lewisham) }
      let(:romford) { build(:location, :romford) }
      let(:manchester) { build(:location, :manchester) }
      let(:cambridge) { build(:location, :cambridge) }
      let(:bristol) { build(:location, :bristol) }
      let(:cardiff) { build(:location, :cardiff) }
      let(:watford) { build(:location, :watford) }
      let(:woking) { build(:location, :woking) }
      let(:guildford) { build(:location, :guildford) }
      let(:oxford) { build(:location, :oxford) }
      let(:edinburgh) { build(:location, :edinburgh) }
      let(:london_provider) { create(:provider, provider_name: "London university") }

      let!(:course_london_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Mathematics (London)",
            provider: london_provider,
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: london.latitude, longitude: london.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 0.0,
        )
      end

      let!(:course_canary_wharf_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Science (Canary Wharf)",
            provider: london_provider,
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: canary_wharf.latitude, longitude: canary_wharf.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 4.46,
        )
      end

      let!(:course_lewisham_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Science (Lewisham)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: lewisham.latitude, longitude: lewisham.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 6.07,
        )
      end

      let!(:course_romford_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Science (Romford)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: romford.latitude, longitude: romford.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 14.36,
        )
      end

      let!(:course_watford_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Music (Watford)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: watford.latitude, longitude: watford.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 15.4,
        )
      end

      let!(:course_woking_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Engineering (Woking)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: woking.latitude, longitude: woking.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 22.62,
        )
      end

      let!(:course_guildford_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Art (Guildford)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: guildford.latitude, longitude: guildford.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 26.75,
        )
      end

      let!(:course_cambridge_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Chemistry (Cambridge)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: cambridge.latitude, longitude: cambridge.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 49.38,
        )
      end

      let!(:course_oxford_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Biology (Oxford)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: oxford.latitude, longitude: oxford.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 51.25,
        )
      end

      let!(:course_bristol_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "English (Bristol)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: bristol.latitude, longitude: bristol.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 105.92,
        )
      end

      let!(:course_cardiff_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Citizenship (Cardiff)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: cardiff.latitude, longitude: cardiff.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 131.26,
        )
      end

      let!(:course_manchester_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Biology (Manchester)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: manchester.latitude, longitude: manchester.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 162.79,
        )
      end

      let!(:course_edinburgh_result) do
        test_search_result_wrapper_klass.new(
          create(
            :course,
            name: "Physics (Edinburgh)",
            site_statuses: [
              create(
                :site_status,
                :findable,
                site: create(:site, latitude: edinburgh.latitude, longitude: edinburgh.longitude),
              ),
            ],
          ),
          minimum_distance_to_search_location: 331.6,
        )
      end

      it_behaves_like "location search results", radius: 1 do
        let(:expected) { [course_london_result] }
      end

      it_behaves_like "location search results", radius: 5 do
        let(:expected) { [course_london_result, course_canary_wharf_result] }
      end

      it_behaves_like "location search results", radius: 10 do
        let(:expected) do
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
          ]
        end
      end

      it_behaves_like "location search results", radius: 15 do
        let(:expected) do
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
            course_romford_result,
          ]
        end
      end

      it_behaves_like "location search results", radius: 20 do
        let(:expected) do
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
            course_romford_result,
            course_watford_result,
          ]
        end
      end

      it_behaves_like "location search results", radius: 25 do
        let(:expected) do
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
            course_romford_result,
            course_watford_result,
            course_woking_result,
          ]
        end
      end

      it_behaves_like "location search results", radius: 50 do
        let(:expected) do
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
            course_romford_result,
            course_watford_result,
            course_woking_result,
            course_guildford_result,
            course_cambridge_result,
          ]
        end
      end

      it_behaves_like "location search results", radius: 100 do
        let(:expected) do
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
            course_romford_result,
            course_watford_result,
            course_woking_result,
            course_guildford_result,
            course_cambridge_result,
            course_oxford_result,
          ]
        end
      end

      it_behaves_like "location search results", radius: 200 do
        let(:expected) do
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
            course_romford_result,
            course_watford_result,
            course_woking_result,
            course_guildford_result,
            course_cambridge_result,
            course_oxford_result,
            course_bristol_result,
            course_cardiff_result,
            course_manchester_result,
          ]
        end
      end

      context "when radius is nil default radius to 10 miles" do
        it_behaves_like "location search results", radius: nil do
          let(:expected) do
            [
              course_london_result,
              course_canary_wharf_result,
              course_lewisham_result,
            ]
          end
        end
      end

      context "when radius is invalid default radius to 10 miles" do
        it_behaves_like "location search results", radius: "10ºdegree" do
          let(:expected) do
            [
              course_london_result,
              course_canary_wharf_result,
              course_lewisham_result,
            ]
          end
        end
      end

      context "when radius is blank default radius to 10 miles" do
        it_behaves_like "location search results", radius: "" do
          let(:expected) do
            [
              course_london_result,
              course_canary_wharf_result,
              course_lewisham_result,
            ]
          end
        end
      end

      context "when latitude and longitude are given" do
        it "always order by distance and ignores the order param" do
          %w[
            course_name_ascending
            course_name_descending
            provider_name_ascending
            provider_name_descending
          ].each do |order|
            results = described_class.call(
              params: {
                latitude: london.latitude,
                longitude: london.longitude,
                radius: 10,
                order:,
              },
            )
            expect(results).to match_collection(
              [
                course_london_result,
                course_canary_wharf_result,
                course_lewisham_result,
              ],
              attribute_names: %w[name minimum_distance_to_search_location],
            )
          end
        end

        it "always order by distance when search by provider" do
          results = described_class.call(
            params: {
              latitude: london.latitude,
              longitude: london.longitude,
              radius: 10,
              provider_code: course_london_result.provider_code,
            },
          )
          expect(results).to match_collection(
            [
              course_london_result,
              course_canary_wharf_result,
            ],
            attribute_names: %w[name minimum_distance_to_search_location],
          )
        end
      end
    end

    describe "SQL injection tests for location search" do
      let(:london) { build(:location, :london) }
      let(:valid_latitude) { 51.5074 }
      let(:valid_longitude) { -0.1278 }
      let(:valid_radius) { 10 }

      before do
        create(
          :course,
          site_statuses: [
            create(
              :site_status,
              :findable,
              site: create(:site, latitude: london.latitude, longitude: london.longitude),
            ),
          ],
        )
      end

      it "does not allow SQL injection via latitude" do
        malicious_latitude = "1; DROP TABLE #{Course.table_name}; --"
        params = { latitude: malicious_latitude, longitude: valid_longitude, radius: valid_radius }

        expect { described_class.call(params: params) }.to raise_error(
          ArgumentError, "invalid value for Float(): \"#{malicious_latitude}\""
        )
      end

      it "does not allow SQL injection via longitude" do
        malicious_longitude = "1; DROP TABLE #{SiteStatus.table_name}; --"
        params = { latitude: valid_latitude, longitude: malicious_longitude, radius: valid_radius }

        expect { described_class.call(params: params) }.to raise_error(
          ArgumentError, "invalid value for Float(): \"#{malicious_longitude}\""
        )
      end

      it "does not allow SQL injection via radius" do
        malicious_radius = "10; DELETE FROM #{Course.table_name} WHERE 1=1; --"
        params = { latitude: valid_latitude, longitude: valid_longitude, radius: malicious_radius }

        expect(described_class.new(params:).radius_in_miles).to be(10)
      end
    end

    context "when ordering" do
      let(:niot_provider) { create(:provider, provider_name: "Niot University") }
      let(:essex_provider) { create(:provider, provider_name: "Essex University") }
      let(:oxford_provider) { create(:provider, provider_name: "Oxford University") }
      let(:manchester_provider) { create(:provider, provider_name: "Manchester University") }

      let!(:biology) do
        create(:course, :with_full_time_sites, name: "Biology", provider: niot_provider)
      end
      let!(:chemistry) do
        create(:course, :with_full_time_sites, name: "Chemistry", provider: essex_provider)
      end
      let!(:mathematics) do
        create(:course, :with_full_time_sites, name: "Mathematics", provider: oxford_provider)
      end
      let!(:art_and_design) do
        create(:course, :with_full_time_sites, name: "Art and Design", provider: manchester_provider)
      end

      context "when ordering by course name ascending" do
        let(:params) { { order: "course_name_ascending" } }

        it "returns courses ordered by course name ascending" do
          expect(results).to match_collection(
            [
              art_and_design,
              biology,
              chemistry,
              mathematics,
            ],
            attribute_names: %w[name],
          )
        end
      end

      context "when ordering by course name descending" do
        let(:params) { { order: "course_name_descending" } }

        it "returns courses ordered by course name descending" do
          expect(results).to match_collection(
            [
              mathematics,
              chemistry,
              biology,
              art_and_design,
            ],
            attribute_names: %w[name],
          )
        end
      end

      context "when ordering by provider name ascending" do
        let(:params) { { order: "provider_name_ascending" } }

        it "returns courses ordered by provider name ascending" do
          expect(results).to match_collection(
            [
              essex_provider.courses,
              manchester_provider.courses,
              niot_provider.courses,
              oxford_provider.courses,
            ].flatten,
            attribute_names: %w[name provider_name],
          )
        end
      end

      context "when ordering by provider name descending" do
        let(:params) { { order: "provider_name_descending" } }

        it "returns courses ordered by provider name descending" do
          expect(results).to match_collection(
            [
              oxford_provider.courses,
              niot_provider.courses,
              manchester_provider.courses,
              essex_provider.courses,
            ].flatten,
            attribute_names: %w[name],
          )
        end
      end

      context "when searching by provider name" do
        let(:provider) { create(:provider, provider_name: "Manchester University") }
        let!(:manchester_computing_course) do
          create(:course, :with_full_time_sites, name: "Computing", provider:)
        end
        let!(:manchester_biology_course) do
          create(:course, :with_full_time_sites, name: "Biology", provider:)
        end
        let!(:manchester_science_course) do
          create(:course, :with_full_time_sites, name: "Science", provider:)
        end
        let!(:manchester_primary_course) do
          create(:course, :with_full_time_sites, name: "Primary", provider:)
        end
        let!(:manchester_art_and_design_course) do
          create(:course, :with_full_time_sites, name: "Art and design", provider:)
        end
        let(:params) { { provider_code: provider.provider_code } }

        it "order courses by ascending order" do
          expect(results).to match_collection(
            [
              manchester_art_and_design_course,
              manchester_biology_course,
              manchester_computing_course,
              manchester_primary_course,
              manchester_science_course,
            ],
            attribute_names: %w[id name provider_name],
          )
        end
      end
    end

    context "when searching by start date" do
      let(:current_recruitment_cycle_year) { RecruitmentCycle.current.year.to_i }
      let!(:january_course) do
        create(:course, :with_full_time_sites, name: "Art and design", start_date: Time.zone.local(current_recruitment_cycle_year, 1, 1))
      end
      let!(:august_course) do
        create(:course, :with_full_time_sites, name: "Biology", start_date: Time.zone.local(current_recruitment_cycle_year, 8, 1))
      end
      let!(:beginning_of_september_course) do
        create(:course, :with_full_time_sites, name: "Computing", start_date: Time.zone.local(current_recruitment_cycle_year, 9, 1))
      end
      let!(:middle_of_september_course) do
        create(:course, :with_full_time_sites, name: "English", start_date: Time.zone.local(current_recruitment_cycle_year, 9, 15))
      end
      let!(:end_of_september_course) do
        create(:course, :with_full_time_sites, name: "Primary with english", start_date: Time.zone.local(current_recruitment_cycle_year, 9, 30))
      end
      let!(:october_course) do
        create(:course, :with_full_time_sites, name: "Spanish", start_date: Time.zone.local(current_recruitment_cycle_year, 10, 1))
      end

      context "when searching for only september courses" do
        let(:params) { { start_date: %w[september] } }

        it "returns courses that starts in september" do
          expect(results).to match_collection(
            [
              beginning_of_september_course,
              middle_of_september_course,
              end_of_september_course,
            ],
            attribute_names: %w[id name start_date],
          )
        end
      end

      context "when searching for all other course start dates" do
        let(:params) { { start_date: %w[all_other_dates] } }

        it "returns courses that starts in all other months except september" do
          expect(results).to match_collection(
            [
              january_course,
              august_course,
              october_course,
            ],
            attribute_names: %w[id name start_date],
          )
        end
      end

      context "when searching for all options" do
        let(:params) { { start_date: %w[september all_other_dates] } }

        it "returns all courses" do
          expect(results).to match_collection(
            [
              january_course,
              august_course,
              beginning_of_september_course,
              middle_of_september_course,
              end_of_september_course,
              october_course,
            ],
            attribute_names: %w[id name start_date],
          )
        end
      end

      context "when searching for invalid start date value" do
        let(:params) { { start_date: %w[something] } }

        it "returns all courses" do
          expect(results).to match_collection(
            [
              january_course,
              august_course,
              beginning_of_september_course,
              middle_of_september_course,
              end_of_september_course,
              october_course,
            ],
            attribute_names: %w[id name start_date],
          )
        end
      end
    end
  end
end
