# frozen_string_literal: true

module SubjectHelper
module_function

  def subject_name_in_sentence(name)
    downcased = name.sub(/^[[:alpha:]]/, &:downcase)
    Subject::LANGUAGE_PROPER_NOUNS.reduce(downcased) do |memo, proper_noun|
      memo.gsub(/\b#{Regexp.escape(proper_noun)}\b/i, proper_noun)
    end
  end
end
