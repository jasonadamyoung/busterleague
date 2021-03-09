# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class StatSheetsController < ApplicationController
  before_action :signin_required

  def index
    @stat_sheets = StatSheet.order(:updated_at)
    @stat_sheet = StatSheet.new
  end

  def create
    if(!@currentowner&.is_admin?)
      flash[:error] = "You must be an application admin to upload stat sheets."
      return redirect_to stat_sheets_url
    end


    if(stat_sheet_params[:sheet].blank?)
      flash[:error] = "No file provided."
      return redirect_to stat_sheets_url
    end

    create_params = stat_sheet_params.merge(owner_id: @currentowner.id)


    begin
      @stat_sheet = StatSheet.create(create_params)
    rescue ActiveRecord::RecordNotUnique => exception
      flash[:error] = "You have already uploaded this sheet."
      return redirect_to stat_sheets_url
    end

    if(@stat_sheet.valid?)
      flash[:success] = "Your stat sheet has been uploaded."
      return redirect_to stat_sheets_url
    else
      flash[:error] = @stat_sheet.errors.join(',')
      return redirect_to stat_sheets_url
    end

  end




  private

  def stat_sheet_params
    params[:stat_sheet].permit(:sheet)
  end

end
