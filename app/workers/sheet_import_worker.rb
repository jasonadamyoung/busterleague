# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class SheetImportWorker
  include Sidekiq::Worker

  def perform(stat_sheet_id)
    begin
      stat_sheet = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless ( upload.processing_status == Upload::READY_FOR_STATS )


    def processdata
      data_to_process = self.get_xlsx_data
      first_row = data_to_process.shift
      if(!first_row['whip'].nil?)
        data_to_process.each do |datahash|
          RealPitchingStat.create_or_update_stat(datahash)
        end
      else
        data_to_process.each do |datahash|
          RealBattingStat.create_or_update_stat(datahash)
        end
      end
    end

  end
end