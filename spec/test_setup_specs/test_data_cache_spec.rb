require "rspec"

describe "TestDataCache" do
  context "cache pre-filled" do
    before(:all) do
      TestDataCache.create_and_cache_test_records
    end

    after(:all) do
      TestDataCache.clear
    end

    it "finds trait pre-defined in test setup [:primary, :unpublished]" do
      allow(FactoryBot).to receive(:create)

      course = TestDataCache.get(:course, :primary, :unpublished)

      expect(course.name).to eq("unpublished course name")
      expect(FactoryBot).to_not have_received(:create)
    end

    it "finds trait pre-defined in test setup [:unpublished, :primary]" do
      course = TestDataCache.get(:course, :unpublished, :primary)

      expect(course.name).to eq("unpublished course name")
    end

    it "raises for traits not pre-defined in test setup [:published, :primary, :resulting_in_pgce_with_qts]" do
      expect {
        TestDataCache.get(
          :course, :primary, :resulting_in_pgce_with_qts, :unpublished
        )
      }.to raise_error(
        <<~ERR_MSG,
          No predefined course for these traits: [:primary, :resulting_in_pgce_with_qts, :unpublished].
          Either add it to test_setup.rb or if it's used frequently, just create
          a FactoryBot factory instance.
        ERR_MSG
     )
    end

    it "raises for unknown Factory types" do
      expect {
        TestDataCache.get(:foo, :bar, :raz)
      }.to raise_error(
        <<~ERR_MSG,
          Unknown model type 'foo' for traits '[:bar, :raz]'.
          You need to add 'foo' to TestSetup or use a standard FactoryBot factory.
        ERR_MSG
     )
    end

    it "returns the same course.id for multiple calls to get" do
      cache1 = TestDataCache.get(:course, :primary, :unpublished)
      cache2 = TestDataCache.get(:course, :primary, :unpublished)
      # check same record is returned every time
      expect(cache1.id).not_to be(nil)
      expect(cache1.id).to be(cache2.id)
    end
  end

  context "cache empty" do
    before(:all) do
      TestDataCache.clear
    end

    after(:all) do
      TestDataCache.clear
    end

    it "creates a new FactoryBot instance" do
      allow(FactoryBot).to receive(:create)

      TestDataCache.get(:course, :primary, :unpublished)

      expect(FactoryBot).to have_received(:create).with(:course, :primary, :unpublished)
    end
  end
end
