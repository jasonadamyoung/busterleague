class AddPositionToOwnerRanks < ActiveRecord::Migration[5.2]
  def change
    add_column(:draft_owner_ranks, :pos_sp, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_rp, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_c, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_1b, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_2b, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_3b, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_ss, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_lf, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_cf, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_rf, :integer, null: true, default: 9999)
    add_column(:draft_owner_ranks, :pos_dh, :integer, null: true, default: 9999)
  end
end
