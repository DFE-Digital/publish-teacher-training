module MapitHelper
  class MapitStub
    def self.body(travel_to_work_area: "London", london_borough: "Westminster City Council")
      {
        "163653": {
          "parent_area": nil,
          "generation_high": 41,
          "all_names": {},
          "id": 163653,
          "codes": {
            "gss": "E30000234",
          },
          "name": travel_to_work_area,
          "country": "E",
          "type_name": "Travel to Work Areas",
          "generation_low": 38,
          "country_name": "England",
          "type": "TTW",
        },
        "2504": {
          "parent_area": nil,
          "generation_high": 41,
          "all_names": {},
          "id": 2504,
          "codes": {
            "unit_id": "11164",
            "ons": "00BK",
            "gss": "E09000033",
            "local-authority-eng": "WSM",
            "local-authority-canonical": "WSM",
          },
          "name": london_borough,
          "country": "E",
          "type_name": "London borough",
          "generation_low": 1,
          "country_name": "England",
          "type": "LBO",
        },
      }.to_json
    end
  end
end
