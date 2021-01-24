# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::RankingValuesController < Draft::BaseController
  before_action :signin_required
  before_action :noidletimeout

  def setrv
    # all the work for this is actually done in the
    # check_for_ranking before_action - we'll just
    # redirect here - or ship ourselves over to new...
    # if that was requested
    if(!params[:prv].nil? and params[:prv] == 'new')
      return redirect_to(new_ranking_value_url(:playertype => RankingValue::PITCHER))
    elsif(!params[:brv].nil? and params[:brv] == 'new')
      return redirect_to(new_ranking_value_url(:playertype => RankingValue::BATTER))
    elsif(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(root_url)
    end
  end

  def setor
    # all the work for this is actually done in the
    # check_for_ranking before_action - we'll just
    # redirect here - or ship ourselves over to new...
    # if that was requested
    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(root_url)
    end
  end

  def index
    # @pitching_rankingvalues = @currentowner.ranking_values.pitching
    # @batting_rankingvalues = @currentowner.ranking_values.batting
    @rankingvalues = @currentowner.ranking_values

    if(!params[:clearthem].nil?)
      cookies[:prv] = nil
      cookies[:brv] = nil
    end
  end

  def new
    if(!params[:playertype].blank? and params[:playertype].to_i == RankingValue::BATTER)
      @playertype = RankingValue::BATTER
      @rankingattributes = Stat::BATTING_DIRECTIONS.keys.sort
    else
      @playertype = RankingValue::PITCHER
      @rankingattributes = Stat::PITCHING_DIRECTIONS.keys.sort
    end
    @new_rankingvalue = RankingValue.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @new_rankingvalue = RankingValue.new(:owner => @currentowner, :playertype => params[:ranking_value][:playertype] )
    if(params[:ranking_value][:playertype] == RankingValue::BATTER)
      @playertype = RankingValue::BATTER
      @rankingattributes = Stat::BATTING_DIRECTIONS.keys.sort
    else
      @playertype = RankingValue::PITCHER
      @rankingattributes = Stat::PITCHING_DIRECTIONS.keys.sort
    end

    if(params[:ranking_value][:label].blank?)
      flash[:error] = "Please provide a label for this ranking"
      return render :action => "new"
    else
      @new_rankingvalue.label = params[:ranking_value][:label]
    end

    if(params[:attributes].blank?)
      flash[:error] = "Please add some ranking attributes"
      return render :action => "new"
    end

    attributes = params[:attributes]
    importances = params[:importances]
    formula = []
    attributes.uniq.each_with_index do |attribute, index|
      importance = importances[index].blank? ? 1 : importances[index].to_i
      formula << {:column => attribute, :importance => importance}
    end

    if(rv = RankingValue.where(:playertype => params[:ranking_value][:playertype]).where(:label => params[:ranking_value][:label]).where(:owner_id => @currentowner.id).first)
      # already have one - let's overwrite
      rv.update_attribute(:formula, formula)
      rv.create_or_update_rankings
      flash[:notice] = 'Ranking value was successfully updated.'
    else
      @new_rankingvalue.formula = formula
      @new_rankingvalue.save
      @new_rankingvalue.create_or_update_rankings
      flash[:notice] = 'Ranking value was successfully created.'
      SlackIt.post(message: "#{@currentowner.nickname} created a new ranking value")
    end
    return redirect_to :action => "index"
  end

  def destroy
    @rv = RankingValue.find(params[:id])
    if(@rv.owner == @currentowner)
      @rv.destroy
      SlackIt.post(message: "#{@currentowner.nickname} deleted a ranking value")
    end
    redirect_to(ranking_values_url)
  end

  private

  def ranking_value_params
    params.permit!
  end
end
