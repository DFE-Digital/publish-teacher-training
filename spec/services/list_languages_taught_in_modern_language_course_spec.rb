describe ListLanguagesTaughtInModernLanguageCourse do
  describe '#call' do
    context 'when the course is for Modern Languages (Spanish with German)' do
      let(:course_name) { 'Modern Languages (Spanish with German)' }
      let(:ucas_subject_names) do
        [
          'Spanish',
          'Secondary',
          'Languages',
          'German',
          'Languages (European)'
        ]
      end

      subject { described_class.call(course_name, ucas_subject_names) }

      it { should match_array(%w[Spanish German]) }
    end
  end
end
