# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadsController < ApplicationController
  before_action :signin_required

  def index
    @uploads = Upload.order(:updated_at)
    @upload = Upload.new
  end

  def create
    if(!@currentowner&.is_admin?)
      flash[:error] = "You must be an application admin to upload archives."
      return redirect_to uploads_url
    end


    if(upload_params[:archive].blank?)
      flash[:error] = "No file provided."
      return redirect_to uploads_url
    end

    create_params = upload_params.merge(owner_id: @currentowner.id)


    begin
      @upload = Upload.create(create_params)
    rescue ActiveRecord::RecordNotUnique => exception
      flash[:error] = "You have already uploaded this archive file."
      return redirect_to uploads_url
    end

    if(@upload.valid?)
      flash[:success] = "Your file has been uploaded."
      return redirect_to uploads_url
    else
      flash[:error] = @upload.errors.join(',')
      return redirect_to uploads_url
    end

  end



  private

  def upload_params
    params[:upload].permit(:archive)
  end

end
