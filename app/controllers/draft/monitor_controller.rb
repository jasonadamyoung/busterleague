# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class MonitorController < ApplicationController
  skip_before_action :check_for_ranking, :check_for_draftstatus, :check_for_stat_preference
  before_action :signin_optional

  def index
    if File.exist?(Rails.root.join("REVISION"))
      revision = File.read(Rails.root.join("REVISION")).chomp
    else
      revision = 'unknown'
    end

    returninformation = {'revision' => revision, 'success' => true}
    return render :json => returninformation.to_json, :status => :ok
  end

end