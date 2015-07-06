class ProposedOrganisationsController < BaseOrganisationsController
  layout 'two_columns_with_map', except: [:index]
  before_filter :require_superadmin_or_recent_creation, only: [:show]

  def index
    @proposed_organisations = ProposedOrganisation.all
  end

  def update
    unless current_user.try(:superadmin?)
      flash[:warning] = PERMISSION_DENIED
      redirect_to root_path and return false
    end
    proposed_org = ProposedOrganisation.find params[:id]
    if update_param == "accept"
      flash[:notice] = "You have approved the following organisation"
      redirect_to organisation_path(proposed_org.accept_proposal) and return false
    else
      proposed_org.destroy
      redirect_to proposed_organisations_path
    end
  end

  def new
    @proposed_organisation = ProposedOrganisation.new 
    @categories_start_with = Category.first_category_name_in_each_type
    @user_id = session[:user_id] || current_user.try(:id)
  end

  def create
    org_params = ProposedOrganisationParams.build params
    usr = User.find params[:proposed_organisation][:user_id] if params[:proposed_organisation][:user_id]
    @proposed_organisation = ProposedOrganisation.new(ProposedOrganisationParams.without_categories(params))
    if @proposed_organisation.invalid?
      flash[:error] =  @proposed_organisation.errors.first[1]
      @categories_start_with = Category.first_category_name_in_each_type
      @categories_selected = collect_selected_categories
      render("new") and return false
    end
    @proposed_organisation = ProposedOrganisation.new(org_params)
    @proposed_organisation.users << [usr] if usr
    if @proposed_organisation.save!
      session[:proposed_organisation_id] = @proposed_organisation.id
      redirect_to @proposed_organisation, notice: 'Organisation is pending admin approval.'
    else
      redirect_to new_proposed_organisation_path and return false
    end
  end

  def show
    @proposed_organisation = ProposedOrganisation.find(params[:id])
    #refactor this into model
    @proposer_email = @proposed_organisation.users.first.email if !@proposed_organisation.users.empty?
    @markers = build_map_markers([@proposed_organisation])
  end

  private

  def require_superadmin_or_recent_creation
    unless session[:proposed_organisation_id] || current_user.try(:superadmin)
      flash[:notice] = PERMISSION_DENIED
      redirect_to root_path
    end
  end
  def collect_selected_categories
    category_params = ProposedOrganisationParams.just_categories(params)
    cats = category_params["category_organisations_attributes"].select do |key,value|
      value["_destroy"] == "0"
    end
    cats.map{|k,v| v["category_id"]}
  end
end

def update_param
  params.require(:proposed_organisation).require(:action)
end
class ProposedOrganisationParams
  def self.build params
    params.require(:proposed_organisation).permit(
      :superadmin_email_to_add,
      :description,
      :address,
      :publish_address,
      :postcode,
      :email,
      :publish_email,
      :website,
      :publish_phone,
      :donation_info,
      :name,
      :telephone,
      :non_profit,
      :works_in_harrow,
      :registered_in_harrow,
      category_organisations_attributes: [:_destroy, :category_id, :id]
    )
  end
  def self.just_categories params
    params.require(:proposed_organisation).permit(category_organisations_attributes: [:_destroy, :category_id, :id])
  end
  def self.without_categories params
    params.require(:proposed_organisation).permit(
      :superadmin_email_to_add,
      :description,
      :address,
      :publish_address,
      :postcode,
      :email,
      :publish_email,
      :website,
      :publish_phone,
      :donation_info,
      :name,
      :telephone,
      :non_profit,
      :works_in_harrow,
      :registered_in_harrow
    )
  end
end
