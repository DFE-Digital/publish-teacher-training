# frozen_string_literal: true

require "rails_helper"
require_relative "query_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  include QueryHelper

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
    let(:cambridge) { build(:location, :cambridge) }
    let(:watford) { build(:location, :watford) }
    let(:woking) { build(:location, :woking) }
    let(:guildford) { build(:location, :guildford) }
    let(:oxford) { build(:location, :oxford) }
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

    it_behaves_like "location search results", radius: 10 do
      let(:expected) do
        [
          course_london_result,
          course_canary_wharf_result,
          course_lewisham_result,
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
      it "defaults to ordering by distance when no order param is given" do
        results = described_class.call(
          params: {
            latitude: london.latitude,
            longitude: london.longitude,
            radius: 10,
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

      it "respects the explicit order param when provided" do
        results = described_class.call(
          params: {
            latitude: london.latitude,
            longitude: london.longitude,
            radius: 10,
            order: "course_name_ascending",
          },
        )
        expect(results).to match_collection(
          [
            course_london_result,
            course_canary_wharf_result,
            course_lewisham_result,
          ],
          attribute_names: %w[name],
        )
      end

      it "defaults to ordering by distance when search by provider" do
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

  context "when location search with same placement schools" do
    let(:london) { build(:location, :london) }
    let(:shared_site) { create(:site, latitude: london.latitude, longitude: london.longitude) }

    let(:zebra_provider) { create(:provider, provider_name: "Zebra University") }
    let(:apple_provider) { create(:provider, provider_name: "Apple University") }
    let(:middle_provider) { create(:provider, provider_name: "Middle University") }

    let!(:course_at_shared_site_zebra) do
      create(
        :course,
        name: "Mathematics",
        provider: zebra_provider,
        site_statuses: [
          create(:site_status, :findable, site: shared_site),
        ],
      )
    end

    let!(:course_at_shared_site_apple) do
      create(
        :course,
        name: "Biology",
        provider: apple_provider,
        site_statuses: [
          create(:site_status, :findable, site: shared_site),
        ],
      )
    end

    let!(:course_at_shared_site_middle) do
      create(
        :course,
        name: "Chemistry",
        provider: middle_provider,
        site_statuses: [
          create(:site_status, :findable, site: shared_site),
        ],
      )
    end

    it "orders courses at the same placement school by provider name A-Z" do
      params = { latitude: london.latitude, longitude: london.longitude, radius: 10 }
      results = described_class.call(params:)

      expect(results).to match_collection(
        [
          course_at_shared_site_apple,
          course_at_shared_site_middle,
          course_at_shared_site_zebra,
        ],
        attribute_names: %w[name provider_name],
      )
    end

    context "when courses are at different distances with some sharing placement schools" do
      let(:nearby_site) { create(:site, latitude: london.latitude + 0.01, longitude: london.longitude + 0.01) }

      let(:yankee_provider) { create(:provider, provider_name: "Yankee University") }
      let(:bravo_provider) { create(:provider, provider_name: "Bravo University") }

      let!(:course_at_nearby_site_yankee) do
        create(
          :course,
          name: "Physics",
          provider: yankee_provider,
          site_statuses: [
            create(:site_status, :findable, site: nearby_site),
          ],
        )
      end

      let!(:course_at_nearby_site_bravo) do
        create(
          :course,
          name: "English",
          provider: bravo_provider,
          site_statuses: [
            create(:site_status, :findable, site: nearby_site),
          ],
        )
      end

      it "orders by distance first, then by provider name for same distance" do
        params = { latitude: london.latitude, longitude: london.longitude, radius: 10 }
        results = described_class.call(params:)

        expect(results.map { |c| c.provider.provider_name }).to eq([
          "Apple University",
          "Middle University",
          "Zebra University",
          "Bravo University",
          "Yankee University",
        ])
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
end
