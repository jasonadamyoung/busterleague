# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module CleanupTools
  extend ActiveSupport::Concern

  def dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

end