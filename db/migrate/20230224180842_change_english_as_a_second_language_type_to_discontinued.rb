# frozen_string_literal: true

class ChangeEnglishAsASecondLanguageTypeToDiscontinued < ActiveRecord::Migration[7.0]
  def change
    ModernLanguagesSubject.find_by(subject_code: '16').update(type: 'DiscontinuedSubject', subject_code: nil)
  end
end
