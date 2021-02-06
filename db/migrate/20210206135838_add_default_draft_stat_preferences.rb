class AddDefaultDraftStatPreferences < ActiveRecord::Migration[5.2]
  def change
    DraftStatPreference.reset_column_information
    psp = DraftStatPreference.create(:owner => Owner.computer,
                                     :label => 'default',
                                     :playertype => DraftStatPreference::PITCHER,
                                     :column_list => DraftStatDistribution.core(DraftStatDistribution::PITCHER))

    bsp = DraftStatPreference.create(:owner => Owner.computer,
                                     :label => 'default',
                                     :playertype => DraftStatPreference::BATTER,
                                     :column_list => DraftStatDistribution.core(DraftStatDistribution::BATTER))
  end
end
