class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy, :rescan]

  def index
    @pagy, @profiles = pagy(Profile.search(params[:q]).order(created_at: :desc), items: 12)
  end

  def show
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to @profile, notice: 'Perfil criado!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: 'Atualizado!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: 'Removido!'
  end

  def rescan
    if @profile.can_rescan?
      RescanProfileJob.perform_later(@profile.id)
      redirect_to @profile, notice: 'Re-escaneamento iniciado!'
    else
      redirect_to @profile, alert: 'Aguarde antes de re-escanear'
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name, :github_url)
  end
end