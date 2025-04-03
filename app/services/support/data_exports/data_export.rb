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

        def find(type)
          all.detect { |d| d.type == type }
        end
      end
    end
  end
end
