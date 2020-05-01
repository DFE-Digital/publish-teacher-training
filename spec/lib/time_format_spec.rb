require "spec_helper"

describe TimeFormat do
  let(:test_class) do
    class TestClass
      include TimeFormat
    end.new
  end

  describe "#precise_time" do
    it "returns the time in the precise format" do
      expect(test_class.precise_time(Time.utc(1993, 9, 1, 3, 14, 15, 926535))).to eq("1993-09-01T03:14:15.926535Z")
    end
  end

  describe "#written_month_year" do
    it "Year and month in written format" do
      expect(test_class.written_month_year(Time.utc(2019, 8))).to eq("August 2019")
    end
  end

  describe "#short_date" do
    it "Short date" do
      expect(test_class.short_date(Time.utc(2000, 8, 25))).to eq("25/08/2000")
    end
  end

  describe "#gov_uk_format" do
    context "AM" do
      it "time and date written in correct format" do
        expect(test_class.gov_uk_format(Time.utc(2000, 8, 25))).to eq("12:00am on 25 August 2000")
      end
    end

    context "PM" do
      it "time and date written in correct format" do
        expect(test_class.gov_uk_format(Time.utc(2000, 8, 25, 14))).to eq("2:00pm on 25 August 2000")
      end
    end
  end
end
