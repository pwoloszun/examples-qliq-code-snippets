require 'spec_helper'

describe Dashboard::BillingAgency::AdminController do

  context "user is authenticated" do
    include Dashboard::BaseControllerHelper

    def resource_sym
      :provider_group_admin
    end

    let(:provider_group_admin) { resource }
    let(:location) { mock("location") }
    let(:location_id) { 123 }

    describe "#show_dashboard" do

      context "location id passed in request params" do

        before(:each) do
          provider_group_should_find_location_by_id
          get :show_dashboard, :location_id => location_id
        end

        it { should_assign_location }
        it { should render_template(:show_dashboard) }
        it { should_assign_resource }
        it { should_assign_back_button_path }
      end

      context "location id not defined" do
        before(:each) do
          provider_group.should_receive(:default_location).and_return(location)
          get :show_dashboard
        end

        it { should_assign_location }
        it { should render_template(:show_dashboard) }
        it { should_assign_resource }
        it { should_assign_back_button_path }
      end
    end

    describe "#add_provider_group" do

      before(:each) do
        provider_group_should_find_location_by_id
        get :add_provider_group, :location_id => location_id
      end

      it { should_assign_location }
      it { should render_template(:add_provider_group) }
      it { should_assign_resource }
      it { should_assign_back_button_path }

    end

    describe "#destroy_provider_group" do

      before(:each) do
        provider_group_should_find_location_by_id
        provider_group.should_receive(:destroy_provider_group).with(location_id, nested_provider_group_id)
        @request.env['HTTP_REFERER'] = 'http://localhost:3000/test'
        delete :destroy_provider_group, :id => nested_provider_group_id, :location_id => location_id
      end

      it { should redirect_to(:back) }

    end

    let(:provider_practice) { true }
    let(:medical_facility) { false }
    let(:nested_provider_group_id) { 12 }
    let(:nested_provider_group) { mock_model(ProviderGroup, :provider_practice? => provider_practice, :medical_facility? => medical_facility, :id => nested_provider_group_id) }

    describe "#edit_provider_group" do


      before(:each) do
        provider_group_should_find_location_by_id
        provider_group.should_receive(:find_provider_group_in_location).with(nested_provider_group_id).and_return(nested_provider_group)
        get :edit_provider_group, :location_id => location_id, :id => nested_provider_group_id
      end

      it "should set group under setup id to flash" do
        should_save_group_under_setup_id
      end

      context "new group is provider practice" do

        it { should_redirect_to_provider_practice_setup() }

      end

      context "new group is medical facility" do

        let(:provider_practice) { false }
        let(:medical_facility) { true }

        it { should_redirect_to_medical_facility_setup }

      end

    end

    describe "#submit_add_provider_group" do

      let(:provider_group_params) { mock("provider group params") }

      before(:each) do
        provider_group_should_find_location_by_id
        provider_group.should_receive(:new_nested_provider_group).with(provider_group_params).and_return(nested_provider_group)
        location.should_receive(:add_provider_group).with(nested_provider_group)
        post :submit_add_provider_group, :location_id => location_id, :provider_group => provider_group_params
      end

      it "should set group under setup id to flash" do
        should_save_group_under_setup_id
      end

      context "new group is provider practice" do

        it { should_redirect_to_provider_practice_setup }

      end

      context "new group is medical facility" do

        let(:provider_practice) { false }
        let(:medical_facility) { true }

        it { should_redirect_to_medical_facility_setup }

      end

    end

    def should_assign_back_button_path
      should assign_to(:back_button_path).with(dashboard_billing_agency_admin_show_dashboard_path)
    end
  end

  def should_save_group_under_setup_id
    flash[:group_under_setup_id].should == nested_provider_group_id
  end

  def should_redirect_to_provider_practice_setup
    should redirect_to(group_admin_provider_practice_setup_provider_group_step_path)
  end

  def should_redirect_to_medical_facility_setup
    should redirect_to(group_admin_medical_facility_setup_organization_step_path)
  end

end
