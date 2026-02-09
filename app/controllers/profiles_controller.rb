# frozen_string_literal: true

class ProfilesController < ApplicationController
  include Paginatable
  helper ProfilesHelper

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
      handle_update_failure(result)
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
          message: I18n.t("profiles.progress.#{@profile.scraping_status}", default: ""),
          last_error: @profile.last_error
        }
      end
    end
  end

  private

  def handle_update_failure(result)
    case result.failure[:error]
    when :rate_limit_exceeded
      time_remaining = helpers.format_rescan_wait_time(result.failure[:time_remaining])
      redirect_to edit_profile_path(@profile),
                  alert: t("profiles.messages.update_wait", time_remaining: time_remaining)
    else
      @profile = result.failure[:profile]
      render :edit, status: :unprocessable_entity
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
