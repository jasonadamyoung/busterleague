# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module CleanupTools
  extend ActiveSupport::Concern

  module ClassMethods
    def dump_data
      self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY CASCADE;")
    end
  end

end