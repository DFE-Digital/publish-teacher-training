require "rails_helper"

RSpec.describe API::Public::V1::SubjectAreasController do
  describe "#index" do
    context "when there are no subject areas" do
      before do
        allow(SubjectArea).to receive(:active).and_return(double(includes: []))

        get :index
      end

      it "returns empty array of data" do
        expect(json_response["data"]).to eql([])
      end
    end

    context "when subject areas exist" do
      before do
        get :index
      end

      it "returns the correct number of subject areas" do
        expected_count = SubjectArea.active.count
        expect(json_response["data"].size).to eql(expected_count)
      end

      context "with includes" do
        before do
          get :index, params: { include: "subjects" }
        end

        it "returns the requested associated data in the response" do
          subject_area = json_response["data"][0]
          subject_area_relationships = subject_area["relationships"]
          subjects_count = subject_area_relationships.dig("subjects", "data").size

          expect(SubjectArea.find(subject_area["id"]).subjects.count).to eq(subjects_count)
          expect(subject_area_relationships.keys.sort).to eq(%w[subjects])
        end
      end
    end
  end
end
