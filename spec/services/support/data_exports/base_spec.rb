require "rails_helper"

RSpec.describe Support::DataExports::Base do
  context ".to_csv" do
    let(:data) {
      [
        {
          col1: "item1_test1",
          col2: "item1_test2",
          col3: "item1_test3",
          col4: "item1_test4",
          col5: "item1_test5",
        },
        {
          col1: "item2_test1",
          col2: "item2_test2",
          col3: "item2_test3",
          col4: "item2_test4",
          col5: "item2_test5",
        },
      ]
    }

    it "generates CSV from data" do
      res = subject.to_csv(data_for_export: data)
      csv = "col1,col2,col3,col4,col5\nitem1_test1,item1_test2,item1_test3,item1_test4,item1_test5\nitem2_test1,item2_test2,item2_test3,item2_test4,item2_test5\n"
      expect(res).to eql(csv)
    end
  end
end
