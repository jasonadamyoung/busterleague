# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::StatPreferencesController < Draft::BaseController
  before_action :noidletimeout


  def search
    if(!params[:playertype].blank? and params[:playertype].to_i == DraftStatPreference::PITCHER)
      @statattributes = DefinedStat.pitching_statlines.pluck(:name).select{|attribute| attribute =~ %r{#{Regexp.escape(params[:q])}}}
    else
      @statattributes = DefinedStat.batting_statlines.pluck(:name).select{|attribute| attribute =~ %r{#{Regexp.escape(params[:q])}}}
    end

    token_hash = @statattributes.collect{|attribute| {id: attribute, name: attribute}}
    render(json: token_hash)
  end

  def setsp
    # all the work for this is actually done in the
    # check_for_ranking before_action - we'll just
    # redirect here - or ship ourselves over to new...
    # if that was requested
    if(!params[:psp].nil? and params[:psp] == 'new')
      return redirect_to(new_stat_preference_url(:playertype => DraftStatPreference::PITCHER))
    elsif(!params[:bsp].nil? and params[:bsp] == 'new')
      return redirect_to(new_stat_preference_url(:playertype => DraftStatPreference::BATTER))
    elsif(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(draft_root_url)
    end
  end

  def index
    @stat_preferences = @currentowner.draft_stat_preferences

    if(!params[:clearthem].nil?)
      cookies[:psp] = nil
      cookies[:bsp] = nil
    end
  end

  def new
    if(!params[:playertype].blank? and params[:playertype].to_i == DraftStatPreference::PITCHER)
      @playertype = DraftStatPreference::PITCHER
    else
      @playertype = DraftStatPreference::BATTER
    end
    @stat_attributes = DraftStatPreference.available_display_stats(@playertype).sort
    @stat_preference = DraftStatPreference.new(column_list: DraftStatPreference.core_display_stats(@playertype))
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @stat_preference = DraftStatPreference.find(params[:id])
    @playertype = @stat_preference.playertype
    @stat_attributes = DraftStatPreference.available_display_stats(@playertype).sort

    respond_to do |format|
      format.html
    end
  end

  def create
    params.permit!
    @stat_preference = DraftStatPreference.new(params[:stat_preference])
    @stat_preference.owner = @currentowner

    @playertype = @stat_preference.playertype
    @stat_attributes = DraftStatPreference.available_display_stats(@playertype).sort

    if(@stat_preference.label.blank?)
      flash[:error] = "Please provide a label for this display preference."
      return render :action => "new"
    end

    if(@stat_preference.column_list.blank?)
      flash[:error] = "Please add some columns to display"
      return render :action => "new"
    end

    if(@stat_preference.save)
      flash[:notice] = 'Ranking value was successfully created.'
      SlackIt.post(message: "#{@currentowner.nickname} created a new stat preference")
      return redirect_to :action => "index"
    else
      return render :action => "new"
    end
  end


  def update
    @stat_preference = DraftStatPreference.find(params[:id])
    if(@stat_preference.label.blank?)
      flash[:error] = "Please provide a label for this ranking"
      return render :action => "new"
    end

    if(@stat_preference.column_list.blank?)
      flash[:error] = "Please add some columns to display"
      return render :action => "new"
    end

    if(@stat_preference.save)
      flash[:notice] = 'Ranking value was successfully created.'
      SlackIt.post(message: "#{@currentowner.nickname} updated a stat preference")
      return redirect_to :action => "index"
    else
      return render :action => "new"
    end
  end

  def destroy
    @sp = DraftStatPreference.find(params[:id])
    if(@sp.owner == @currentowner)
      @sp.destroy
      SlackIt.post(message: "#{@currentowner.nickname} deleted a stat preference")
    end
    redirect_to(stat_preferences_url)
  end

  private

  def stat_preference_params
    params.permit!
  end

end
