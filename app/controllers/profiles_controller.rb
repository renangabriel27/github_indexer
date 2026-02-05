class ProfilesController < ApplicationController
  before_action :set_profile, only: [ :show, :edit, :update, :destroy, :rescan ]

  def index
    profiles = Profile.all
    search_query = params[:q]
    profiles = profiles.search(search_query) if search_query.present?
    profiles = profiles.order(created_at: :desc)

    @pagy, @profiles = pagy(:offset, profiles, offset: calculate_offset, limit: per_page)
  end

  def show
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to @profile, notice: "Perfil criado!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: "Atualizado!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: "Removido!"
  end

  def rescan
    if @profile.can_rescan?
      RescanProfileJob.perform_later(@profile.id)
      redirect_to @profile, notice: "Re-escaneamento iniciado!"
    else
      redirect_to @profile, alert: "Aguarde antes de re-escanear"
    end
  end

  private

  def calculate_offset
    return params[:offset].to_i if params[:offset].present?

    page = params[:page].to_i
    page = 1 if page < 1

    (page - 1) * per_page
  end

  def per_page
    requested = params[:per_page].to_i
    requested.positive? ? [ requested, 100 ].min : 12
  end

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name, :github_username)
  end
end
