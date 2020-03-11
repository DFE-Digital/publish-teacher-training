describe TimeFormat do
  describe "#precise_time" do
    it "returns the time in the precise format" do
      expect(precise_time(Time.utc(1993, 9, 1, 3, 14, 15, 926535))).to eq("1993-09-01T03:14:15.926535Z")
    end
  end

  describe "#written_month_year" do
    it "Year and month in written format" do
      expect(written_month_year(Time.utc(2019, 8))).to eq("August 2019")
    end
  end

  describe "#short_date" do
    it "Short date" do
      expect(short_date(Time.utc(2000, 8, 25))).to eq("25/08/2000")
    end
  end
end
