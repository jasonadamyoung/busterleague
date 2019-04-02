# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadsController < ApplicationController
  before_action :signin_required
  before_action :check_for_admin

  def index
    @uploads = Upload.order(:archivefile_updated_at)
    @upload = Upload.new
  end

  def create
    create_params = upload_params.merge(owner_id: @currentowner.id)
    if(@upload = Upload.create(create_params))
      SlackIt.post(message: "#{@currentowner.nickname} uploaded a new archive file.")
      returninformation = {'msg' => 'OK!'}
      return render :json => returninformation.to_json, :status => 200
    else
      returninformation = {'msg' => "Unable to upload file: #{@upload.errors.join(',')}"}
      return render :json => returninformation.to_json, :status => 400
    end
  end

  private

  def check_for_admin
    # ToDo
  end

  def upload_params
    params[:upload].permit(:archivefile)
  end

end
