class ChangeTeamedConstant < ActiveRecord::Migration[5.2]
  def change
    # fix so we can order by undrafted
    execute "UPDATE draft_players SET draftstatus = #{DraftPlayer::DRAFT_STATUS_TEAMED} where draftstatus = 1;"
  end
end
