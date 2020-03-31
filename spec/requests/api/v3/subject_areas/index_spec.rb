require "rails_helper"

describe "GET v3 /subject_areas" do
  let(:request_path) { "/api/v3/subject_areas" }
  let(:json_response) { JSON.parse(response.body) }

  before do
    get request_path
  end

  it "returns the correct data" do
    expect(json_response).to eq("data" => [
      {
        "id" => "PrimarySubject",
        "type" => "subject_areas",
        "attributes" => {
          "name" => "Primary",
          "typename" => "PrimarySubject",
        },
        "relationships" => {
          "subjects" => {
            "meta" => {
              "included" => false,
            },
          },
        },
      },
      {
        "id" => "SecondarySubject",
        "type" => "subject_areas",
        "attributes" => {
          "name" => "Secondary",
          "typename" => "SecondarySubject",
        },
        "relationships" => {
          "subjects" => {
            "meta" => {
              "included" => false,
            },
          },
        },
      },
      {
        "id" => "ModernLanguagesSubject",
        "type" => "subject_areas",
        "attributes" => {
          "name" => "Secondary: Modern languages",
          "typename" => "ModernLanguagesSubject",
        },
        "relationships" => {
          "subjects" => {
            "meta" => {
              "included" => false,
            },
          },
        },
      },
      {
        "id" => "FurtherEducationSubject",
        "type" => "subject_areas",
        "attributes" => {
          "name" => "Further education",
          "typename" => "FurtherEducationSubject",
        },
        "relationships" => {
          "subjects" => {
            "meta" => {
              "included" => false,
            },
          },
        },
      },
    ],
    "jsonapi" => {
      "version" => "1.0",
    })
  end

  context "when specifying particular fields" do
    let(:request_path) { "/api/v3/subject_areas?fields[subject_areas]=typename" }

    it "returns the correct data" do
      expect(json_response).to eq("data" => [
        {
          "id" => "PrimarySubject",
          "type" => "subject_areas",
          "attributes" => {
            "typename" => "PrimarySubject",
          },
        },
        {
          "id" => "SecondarySubject",
          "type" => "subject_areas",
          "attributes" => {
            "typename" => "SecondarySubject",
          },
        },
        {
          "id" => "ModernLanguagesSubject",
          "type" => "subject_areas",
          "attributes" => {
            "typename" => "ModernLanguagesSubject",
          },
        },
        {
          "id" => "FurtherEducationSubject",
          "type" => "subject_areas",
          "attributes" => {
            "typename" => "FurtherEducationSubject",
          },
        },
      ],
      "jsonapi" => {
        "version" => "1.0",
      })
    end
  end

  context "when including fields" do
    let(:request_path) { "/api/v3/subject_areas?include=subjects" }

    it "includes the relationship" do
      expect(json_response["data"].first).to eq(
        "id" => "PrimarySubject",
        "type" => "subject_areas",
        "attributes" => {
          "typename" => "PrimarySubject",
          "name" => "Primary",
        },
        "relationships" => {
          "subjects" => {
            "data" => [
              {
                "type" => "subjects",
                "id" => "1",
              },
              {
                "type" => "subjects",
                "id" => "2",
              },
              {
                "type" => "subjects",
                "id" => "3",
              },
              {
                "type" => "subjects",
                "id" => "4",
              },
              {
                "type" => "subjects",
                "id" => "5",
              },
              {
                "type" => "subjects",
                "id" => "6",
              },
              {
                "type" => "subjects",
                "id" => "7",
              },
            ],
          },
        },
      )
    end
  end
end
