class Dashboard::BillingAgency::AdminController < Dashboard::BaseController

  before_filter :assign_group_location
  roles_allowed :group_admin, :system_admin

  include Dashboard::SecuritySettings

  def show_dashboard
  end

  def add_provider_group
  end

  def submit_add_provider_group
    new_provider_group = @provider_group.new_nested_provider_group(params[:provider_group])
    @location.add_provider_group(new_provider_group)
    save_group_under_setup_id(new_provider_group.id)
    redirect_to group_paths(new_provider_group)[:setup]
  end

  def edit_provider_group
    edited_provider_group = @provider_group.find_provider_group_in_location(params[:id])
    save_group_under_setup_id(edited_provider_group.id)
    redirect_to group_paths(edited_provider_group)[:setup]
  end

  def destroy_provider_group
    @provider_group.destroy_provider_group(params[:location_id].to_i, params[:id].to_i)
    redirect_to :back
  end

  protected

  def assign_provider_group
    if current_user.admin?
      @provider_group = ProviderGroup.find(group_under_setup_id)
    else
      remove_group_under_setup_id
      @provider_group = current_user.provider_group
    end
  end

  def resource_sym
    :provider_group_admin
  end

  def assign_menu_items
    @menu_items = [
      {:text => I18n.t("dashboard.context.nav.setup"), :path => group_admin_billing_agency_organization_path},
        {:text => I18n.t("dashboard.context.nav.dashboard"), :path => dashboard_billing_agency_admin_show_dashboard_path},
        {:text => I18n.t("dashboard.context.nav.profile"), :path => dashboard_billing_agency_admin_show_profile_path},
        {:text => I18n.t("dashboard.context.nav.login_activity"), :path => dashboard_billing_agency_admin_login_activity_path},
        {:text => I18n.t("dashboard.context.nav.security_settings"), :path => dashboard_billing_agency_admin_security_settings_path},
        {:text => I18n.t("dashboard.context.nav.support"), :path => "#todo"}
    ]
  end

  private

  def dashboard_path
    dashboard_billing_agency_admin_show_dashboard_path
  end

end
