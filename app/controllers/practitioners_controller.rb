class PractitionersController < ApplicationController
  before_action :authorize_admin!, except: [ :index, :show ]
  before_action :set_practitioner, only: [ :show, :edit, :update, :destroy ]

  def index
    @practitioners = Practitioner.search(params[:search]).order(:name)
  end

  def show
    @appointments = @practitioner.appointments.includes(:patient).upcoming.limit(10)
  end

  def new
    @practitioner = Practitioner.new
  end

  def create
    @practitioner = Practitioner.new(practitioner_params)

    if @practitioner.save
      redirect_to @practitioner, notice: "Profissional cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @practitioner.update(practitioner_params)
      redirect_to @practitioner, notice: "Profissional atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @practitioner.destroy
    redirect_to practitioners_path, notice: "Profissional removido com sucesso!"
  end

  private

  def authorize_admin!
    unless current_user.admin?
      redirect_to practitioners_path, alert: "Você não tem permissão para realizar esta ação."
    end
  end

  def set_practitioner
    @practitioner = Practitioner.find(params[:id])
  end

  def practitioner_params
    params.require(:practitioner).permit(:name, :specialty, :crm, :phone, :user_id)
  end
end
