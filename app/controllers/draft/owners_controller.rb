# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::OwnersController < Draft::BaseController
  before_action :noidletimeout
  before_action :signin_required

  def set_position_pref
    if(params[:draft_owner_position_pref_id])
      if(dopp = DraftOwnerPositionPref.find(params[:draft_owner_position_pref_id]))
        if(dopp.owner_id = @currentowner.id)
          dopp.update_attribute(:prefable_id, params[:prefable_id])
        else
          # no owner match, ignore
        end
      else
        # couldn't find the dopp, ignore
      end
    else
      # validate prefable
      if(params[:prefable_type] and params[:prefable_id] and DraftOwnerPositionPref::ALLOWED_PREFABLES.include?(params[:prefable_type]))
        prefable = Object.const_get(params[:prefable_type]).find(params[:prefable_id])
        if(prefable.owner == @currentowner or prefable.owner == Owner.computer)
          if(dopp = DraftOwnerPositionPref.where(owner: @currentowner).where(prefable_type: params[:prefable_type]).where(player_type: params[:player_type]).where(position: params[:position]).first)
            dopp.update_attribute(:prefable_id, params[:prefable_id])
          else
            # ToDo validate position
            dopp = DraftOwnerPositionPref.create(owner: @currentowner,
                                                prefable_type: params[:prefable_type],
                                                prefable_id: params[:prefable_id],
                                                position: params[:position])
          end
        end
      end
    end
    redirect_to_current_or_root
  end

end
