# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class StatSheetsController < ApplicationController
  before_action :signin_required

  def index
    @stat_sheets = StatSheet.order(:datafile_updated_at)
    @stat_sheet = StatSheet.new
  end

  def create
    if(!@currentowner.is_admin?)
      returninformation = {'msg' => "Unable to upload file: #{@upload.errors.join(',')}"}
      return render :json => returninformation.to_json, :status => 400
    end
    
    create_params = stat_sheet_params.merge(owner_id: @currentowner.id)
    if(@stat_sheet = StatSheet.create(create_params))
      SlackIt.post(message: "#{@currentowner.nickname} uploaded a new stat sheet.")
      returninformation = {'msg' => 'OK!'}
      return render :json => returninformation.to_json, :status => 200
    else
      returninformation = {'msg' => "Unable to upload file: #{@stat_sheet.errors.join(',')}"}
      return render :json => returninformation.to_json, :status => 400
    end
  end

  private

  def stat_sheet_params
    params[:stat_sheet].permit(:datafile)
  end

end
