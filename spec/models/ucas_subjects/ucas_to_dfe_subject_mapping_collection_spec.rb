module UCASSubjects
  describe UCASToDFESubjectMappingCollection do
    let(:config) {
      {
        ["UCAS subject A1", "UCAS subject A2"] => "DfE subject A",
        ["UCAS subject B"] => "DfE subject B",
        {
          course_title_matches: ->(course_title) { course_title =~ /XY/ },
          ucas_subjects: ["UCAS subject W"],
        } => "DfE subject XY",
      }
    }
    subject { described_class.new(config: config) }

    it "applies individual mappings to derive the result" do
      expect(subject.to_dfe_subjects(ucas_subjects: ["UCAS subject A1"], course_title: :anything).map(&:to_s)).
        to eq(["DfE subject A"])
    end

    it "combines multiple mappings to derive the result" do
      expect(
        subject.to_dfe_subjects(
          ucas_subjects: ["UCAS subject A1", "UCAS subject B", "UCAS subject W"],
          course_title: "XY with V",
        ).map(&:to_s),
      ).to match_array(["DfE subject A", "DfE subject B", "DfE subject XY"])
    end

    it "skips mappings that don't match" do
      expect(subject.to_dfe_subjects(ucas_subjects: %w[X Y Z], course_title: "XY")).
        to be_empty
    end
  end
end
