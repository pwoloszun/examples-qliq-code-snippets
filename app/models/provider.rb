class Provider < ActiveRecord::Base

  attr_accessor :referring_provider

  def_delegators :contact_info, :email, :phone, :mobile_phone
  def_delegators :user, :user_roles

  include Validators::UserOwner
  include Validators::ProviderAndNurse
  include Validators::NpiOwner
  include Utils::ProviderNames
  include ProviderGroupOwner
  include ProviderSpeciality
  include UserSipServerIntegration::Resource
  include ApplicationsOwner
  include ProviderCommons

  belongs_to :npi
  belongs_to :contact_info
  belongs_to :user
  belongs_to :practice_address, :class_name => "Address"

  has_many :provider_in_facilities
  has_many :facilities, :through => :provider_in_facilities
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :referring_locations, :class_name => "Location", :join_table => :locations_referring_providers

  accepts_nested_attributes_for :user, :npi, :contact_info, :provider_in_facilities, :practice_address

  after_initialize :init_attributes
  before_validation :set_user_role
  before_destroy :destroy_user, :unless => :is_group_admin?


  class << self

    def new_with_user params, user
      provider = Provider.new(params)
      if provider.is_group_admin?
        user.add_role(UserRole.for_provider)
        provider.user = user
      end
      provider
    end

    def qliq_user provider
      provider = joins(:npi).where("npis.number = ?", provider.npi.number).first
      provider unless provider.nil? || provider.user.nil?
    end

  end

  def update_attributes_with_user params, admin_user
    if remove_group_admin_privileges?(params)
      self.user = User.new
      @new_user_created = true
    elsif add_group_admin_privileges?(params)
      self.user.destroy
      self.user = admin_user
    end
    if update_attributes(params)
      send_confirmation_instructions if @new_user_created
      true
    else
      false
    end
  end

  def send_confirmation_instructions
    user.send_confirmation_instructions unless user.nil? || is_group_admin?
  end

  def default_taxonomy
    NpiSearch::Taxonomy.first
  end

  def referring_provider?
    self.referring_provider || referring_locations.any?
  end

  def qliq_user?
    !Provider.qliq_user(self).nil?
  end

  private

  def init_attributes
    build_user if user.nil? && !referring_provider?
    build_contact_info if contact_info.nil?
    build_npi if npi.nil?
  end

  def set_user_role
    unless self.user.nil?
      self.user.add_role(UserRole.for_provider)
    end
  end

  def remove_group_admin_privileges? params
    is_group_admin? && params[:is_group_admin] == "0"
  end

  def add_group_admin_privileges? params
    !is_group_admin? && params[:is_group_admin] == "1"
  end

  def new_user_created?
    @new_user_created
  end

end
