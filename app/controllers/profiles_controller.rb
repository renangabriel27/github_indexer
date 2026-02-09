# frozen_string_literal: true

class ProfilesController < ApplicationController
  include Paginatable

  before_action :set_profile, only: [ :show, :edit, :update, :destroy, :rescan, :status ]

  def index
    profiles = ProfilesFilterQuery.call(filter_params)
    @pagy, @profiles = pagy(:offset, profiles, offset: calculate_offset, limit: per_page(default: 12))
  end

  def show
  end

  def new
    @profile = Profile.new
  end

  def create
    result = Profiles::CreatorService.call(profile_params)

    if result.success?
      redirect_to result.value![:profile]
    else
      @profile = result.failure[:profile]
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    result = Profiles::UpdaterService.call(@profile, profile_params)

    if result.success?
      redirect_to result.value![:profile], notice: t("profiles.messages.updated")
    else
      @profile = result.failure[:profile]
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: t("profiles.messages.deleted"), status: :see_other
  end

  def rescan
    if @profile.can_rescan?
      @profile.update(scraping_status: :processing)
      RescanProfileJob.perform_later(@profile.id)
      redirect_to @profile
    else
      redirect_to @profile, alert: t("profiles.messages.rescan_wait")
    end
  end

  def status
    respond_to do |format|
      format.json do
        render json: {
          status: @profile.scraping_status,
          message: status_message,
          last_error: @profile.last_error
        }
      end
    end
  end

  private

  def status_message
    case @profile.scraping_status
    when "completed"
      t("profiles.progress.completed")
    when "failed"
      t("profiles.progress.failed")
    when "processing"
      t("profiles.progress.preparing")
    else
      ""
    end
  end

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name, :github_username)
  end

  def filter_params
    params.permit(:q, :status, :order)
  end
end
