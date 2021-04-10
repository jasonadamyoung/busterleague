class NotifyDraftPickChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'notify_draft_pick_channel'

    notify
  end

  def notify
    ActionCable.server.broadcast(
      'notify_draft_pick_channel',
      picked_count: picked_count
    )
  end

  def picked_count
    DraftPick.picked.count
  end
end