# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class SheetImportWorker
  include Sidekiq::Worker

  def perform(stat_sheet_id)
    begin
      stat_sheet = StatSheet.find(stat_sheet_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

  end
end