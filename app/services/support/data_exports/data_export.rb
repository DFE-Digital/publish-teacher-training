# frozen_string_literal: true

module Support
  module DataExports
    class DataExport
      class << self
        def all
          [
            DataExports::UsersExport,
          ].map(&:new)
        end

        def find(id)
          all.detect{|d| d.id == id }
        end
      end
    end
  end
end
