require 'spec_helper'

describe Provider do

  let(:provider) do
    Provider.new({
      :name_prefix => "Dr",
      :first_name => "John",
      :middle_name => "W.",
      :last_name => "Doe",
      :name_suffix => "Jr",
      :credentials => "PhD",
      :contact_info => Factory.build(:contact_info),
      :npi => Factory.build(:npi),
      :taxonomy_code => "XYZ",
      :applications => [:qliq_connect]
    })
  end
  let(:user) { Factory(:user) }

  it { should belong_to(:npi) }
  it { should belong_to(:contact_info) }
  it { should belong_to(:user) }
  it { should have_many(:facilities).through(:provider_in_facilities) }
  it { should have_and_belong_to_many(:locations) }

  it "should delegate #email, #phone to contact_info" do
    [:email, :phone].each do |delegated_method_sym|
      provider.send(delegated_method_sym).should == provider.contact_info.send(delegated_method_sym)
    end
  end

  it "should delegate #user_roles to user" do
    provider.user_roles.should == provider.user.user_roles
  end

  describe "#name" do

    subject { provider.name }

    it { should == "Dr John W. Doe Jr, PhD" }

    context "only first and last name" do

      before(:each) do
        provider.name_prefix = nil
        provider.middle_name = ""
        provider.name_suffix = ""
        provider.credentials = nil
      end

      it { should == "John Doe" }

    end

    context "prefix, first, last, middle name" do

      before(:each) do
        provider.name_suffix = ""
        provider.credentials = nil
      end

      it { should == "Dr John W. Doe" }

    end

  end

  describe "#shortened_name" do

    subject { provider.shortened_name }

    it { should == "J. Doe, PhD" }

    context "no credentials" do

      before(:each) do
        provider.credentials = ""
      end

      it { should == "J. Doe" }

    end

  end

  describe "#after_initialize" do

    before(:each) do
      @provider = Provider.new
    end

    it "should create user" do
      @provider.user.should_not be_nil
    end

    it "should not override user if it was given in constructor" do
      @provider = Provider.new(:user => user)
      @provider.user.should == user
    end

    it "should create contact info" do
      @provider.contact_info.should_not be_nil
    end

    it "should create npi" do
      @provider.npi.should_not be_nil
    end

  end

  describe "#before_validation" do

    let(:email) { "john.doe@test.com" }

    before(:each) do
      @provider = Provider.create!({
        :npi => Npi.new(:number => "1234567890"),
        :first_name => "X",
        :last_name => "Y",
        :contact_info => Factory.build(:contact_info, :email => email),
        :taxonomy_code => "xxx",
        :applications => [:qliq_connect]
      })
    end

    it "should create new user with email and names same as this provider" do
      should_belong_to_user_with(email)
      user_should_hold_same_data_as @provider
    end

    it "should update users email and names from provider" do
      new_email = "xxx2@test.com"
      @provider.contact_info.email = new_email
      @provider.save
      user_should_hold_same_data_as @provider
    end

    def should_belong_to_user_with email
      obj_should_belong_to_user_with_email @provider, email
    end

  end

  describe ".new_with_user" do

    let(:params) { {} }

    before(:each) do
      @provider = Provider.new_with_user(params, user)
    end

    context "i am not this user" do

      it "should create provider with new user" do
        @provider.user.should_not == user
      end

    end

    context "i am this user" do

      let(:params) { {:is_group_admin => true} }

      it "should create provider with given user" do
        @provider.user.should == user
      end

      it "should add provider role to a given user" do
        user.user_roles.should include(UserRole.for_provider)
      end

    end

  end

  describe "#update_attributes_with_user" do

    let(:params) do
      {
        :is_group_admin => new_is_group_admin,
        :contact_info_attributes => {
          :email => email,
          :mobile_phone => "555-555-5555"
        }
      }
    end
    let(:new_is_group_admin) { "0" }
    let(:current_is_group_admin) { true }
    let(:after_update_user) { mock_model(User).as_null_object }

    before(:each) do
      provider.is_group_admin = current_is_group_admin
      provider.save!
      @old_user = provider.user
      mock_new_user_creation if new_user_created?
      provider.update_attributes_with_user(params, user)
      provider.reload
    end

    context "provider was group admin and stops being group admin" do

      let(:new_user_created?) { true }
      let(:email) { "new.email2@test.com" }

      it "should not delete group admin user" do
        User.find(@old_user.id).should_not be_nil
      end

      it "should create new user" do
        provider.user.should_not be_nil
        provider.user.should_not == @old_user
      end

      it "should update attributes" do
        provider.is_group_admin.should be_false
      end

      def mock_new_user_creation
        User.should_receive(:new).any_number_of_times.and_return(after_update_user)
        after_update_user.should_receive(:send_confirmation_instructions)
        provider.should_receive(:user).any_number_of_times.and_return(after_update_user)
      end

    end

    context "provider was not group admin and becomes group admin" do

      let(:new_user_created?) { false }
      let(:current_is_group_admin) { false }
      let(:new_is_group_admin) { "1" }
      let(:email) { user.email }

      it "should delete old user" do
        expect { User.find(@old_user.id) }.to raise_error
      end

      it "should assign given user to provider" do
        provider.user.should == user
      end

    end

  end

  describe "#before_destroy" do

    before(:each) do
      location = Factory(:location)
      location.provider_group = Factory(:provider_group)
      provider.locations << location
    end

    it "should destroy user if provider is not group admin" do
      provider.save!
      provider.destroy
      provider.user.should be_destroyed
    end

    it "should not destroy user if provider is group admin" do
      provider.is_group_admin = true
      provider.save!
      provider.destroy
      provider.user.should_not be_destroyed
    end

  end

  describe "#add_facilities" do
    it "should concat given facilities to already existing" do

      provider.should_receive(:facilities).and_return(facilities)
      provider.add_facilities(new_facilities).should == valid
    end

    def facilities
      f = mock("facilities")
      f.should_receive(:concat).with(new_facilities).and_return(valid)
      f
    end

    let(:valid) { mock("true or false") }
    let(:new_facilities) { mock("new facilities") }
  end

  describe "#group_location" do
    let(:location) { mock("location") }
    let(:location_id) { mock("location id") }

    it "should delegate search to locations" do
      provider.extend(MockUtils)
      provider.should_delegate(:find_location, :to => :provider_group, :with => location_id).and_return(location)
      provider.group_location(location_id).should == location
    end
  end

  describe "#first_location" do

    let(:location) { mock("location") }

    it "should return first location" do
      provider.extend(MockUtils)
      provider.should_delegate(:first, :to => :locations).and_return(location)
      provider.first_location.should == location
    end

  end

  describe "#provider_group" do

    let(:provider_group) { Factory(:provider_group) }

    context "provider belongs to location" do
      let(:location) { Factory(:location, :provider_group => provider_group) }

      it "should return first location provider group" do
        provider.locations << location
        provider.provider_group.should == provider_group
      end

    end

    context "provider belongs to facility" do
      let(:provider_group) { Factory(:medical_facility_provider_group) }

      let(:facility) { Factory(:facility, :provider_group => provider_group) }

      it "should return first location provider group" do
        provider.facilities << facility
        provider.provider_group.should == provider_group
      end

    end

    context "provider does not belong to any location and facility" do

      it "should return nil" do
        provider.provider_group.should be_nil
      end

    end

  end

  describe "#send_confirmation_instructions" do

    let(:user) { mock_model(User) }
    let(:provider) { Provider.new(:user => user) }

    context "provider is group admin" do

      it "should not send confirmation instructions" do
        user.should_not_receive(:send_confirmation_instructions)
        provider.is_group_admin = true
        provider.send_confirmation_instructions
      end

    end

    context "provider is not group admin" do

      it "should not send confirmation instructions" do
        user.should_receive(:send_confirmation_instructions)
        provider.is_group_admin = false
        provider.send_confirmation_instructions
      end

    end

  end

  describe "#destroy_if_orphaned" do

    before(:each) do
      provider.destroy_if_orphaned
    end

    subject { provider }

    context "provider belongs to location" do

      let(:provider_group) { Factory(:provider_group) }

      let(:location) do
        loc = Factory(:location)
        provider_group.add_location(loc)
        loc
      end

      let(:provider) do
        prov = Factory.build(:provider)
        location.add_provider(prov)
        Provider.find(prov.id)
      end

      it { should_not be_destroyed }

    end

    context "provider does not belong to location" do

      context "no facilities" do

        it { should be_destroyed }

      end

      context "facilities present" do

        let(:provider_group) { Factory(:medical_facility_provider_group) }

        let(:facility) do
          fac = Factory.build(:facility)
          provider_group.add_facility(fac)
          fac
        end

        let(:provider) do
          provider_in_facility = Factory.build(:provider_in_facility)
          facility.add_provider_in_facility(provider_in_facility)
          Provider.find(provider_in_facility.provider.id)
        end

        it { should_not be_destroyed }

      end

    end

  end


  describe "returning facilities" do

    let(:provider) { Factory.build(:provider) }
    let(:med_fac1) { mock_medical_facility_facility }
    let(:med_fac2) { mock_medical_facility_facility }
    let(:prov_fac1) { mock_provider_practice_facility }
    let(:prov_fac2) { mock_provider_practice_facility }

    before(:each) do
      provider.add_facilities([med_fac1, med_fac2, prov_fac1, prov_fac2])
    end

    describe "#medical_facility_facilities" do

      subject { provider.medical_facility_facilities }

      it { should == [med_fac1, med_fac2] }

    end

    describe "#provider_practice_facilities" do

      subject { provider.provider_practice_facilities }

      it { should == [prov_fac1, prov_fac2] }

    end

    def mock_medical_facility_facility
      mock_model(Facility, :belongs_to_medical_facility? => true, :belongs_to_provider_practice? => false)
    end

    def mock_provider_practice_facility
      mock_model(Facility, :belongs_to_medical_facility? => false, :belongs_to_provider_practice? => true)
    end

  end

end
