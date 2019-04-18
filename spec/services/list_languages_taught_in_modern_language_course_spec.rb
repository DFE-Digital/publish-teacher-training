describe ListLanguagesTaughtInModernLanguageCourse do
  describe '#call' do
    let(:ucas_subject_names) do
      [
        'Spanish',
        'Secondary',
        'Languages',
        'German',
        'Languages (European)'
      ]
    end

    subject { described_class.call(course, ucas_subject_names) }

    context 'with a secondary course' do
      context 'when the course is for Modern Languages (Spanish with German)' do
        let(:course) do
          build(
            :course,
            :secondary,
            name: 'Modern Languages (Spanish with German)'
          )
        end
        let(:ucas_subject_names) do
          [
            'Spanish',
            'Secondary',
            'Languages',
            'German',
            'Languages (European)'
          ]
        end

        it { should match_array(%w[Spanish German]) }
      end
    end

    context 'with a primary course' do
      let(:course) do
        build(
          :course,
          :primary,
          name: 'Modern Languages (Spanish with German)'
        )
      end

      it { should eq([]) }
    end
  end
end
