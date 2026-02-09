# frozen_string_literal: true

class ProfileStatusChannel < ApplicationCable::Channel
  def subscribed
    profile = Profile.find(params[:id])
    stream_for profile
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
