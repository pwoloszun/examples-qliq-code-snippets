Given /^facility "([^"]*)" contains staff "([^"]*)"$/ do |facility_name, staff_last_name|
  add_existing_staff(Facility.find_by_name(facility_name), staff_last_name)
end

Given /^location "([^"]*)" contains staff "([^"]*)"$/ do |location_name, staff_last_name|
  add_existing_staff(Location.find_by_name(location_name), staff_last_name)
end

def add_existing_staff(staff_owner, staff_last_name)
  staff = Staff.find_by_last_name(staff_last_name)
  staff_owner.add_staff(staff)
end

When /^I press add provider group button$/ do
  When "I follow \"#{I18n.t("summary.provider_groups.add")}\""
end

When /^I select "([^"]*)" group as group type$/ do |group_type|
  @group_type = group_type
  When "I choose \"#{I18n.t("subscribe.#{group_type}")}\""
end

When /^I press create new provider group button$/ do
  When "I press \"#{I18n.t("dashboard.create_provider_group")}\""
end

When /^I enter some provider group data$/ do
  When "I edit provider group data to:", table(%{
      | npi          | 9994567890   |
      | name         | My Group     |
      | address1     | 1 Elm Street |
      | address2     | Suite 3      |
      | zip          | 92345        |
      | phone        | 123-456-7890 |
      | state        | CA           |
      | city         | Santa Clara  |
      | applications |qliq_connect|
  })
end

When /^I enter some location data$/ do
  When "I edit location data to:", table(%{
      | name     | Test1          |
      | address1 | 10 East Street |
      | address2 | Suite 3        |
      | city     | Los Angeles    |
      | state    | CA             |
      | zip      | 90210          |
      | phone    | 555-555-5555   |
      | fax      | 555-555-5555   |
  })
end

When /^I enter some staff data$/ do
  When "I edit staff data to:", table(%{
      | first_name   | John                   |
      | last_name    | Doe                    |
      | email        | joh12345@mycompany.com |
      | mobile_phone | 444-444-5555           |
  })
  And "I check \"Billing\""
end

When /^I enter some provider data$/ do
  When "I edit provider data to:", table(%{
      | npi            | 1234567890         |
      | name_prefix    | Mr                 |
      | first_name     | John               |
      | middle_name    | X.                 |
      | last_name      | Doe                |
      | name_suffix    | Jr                 |
      | credentials    | PhD                |
      | email          | johny.doe4@xxx.com |
      | mobile_phone   | 555-555-5555       |
  })
end

When /^I enter some medical facility provider data$/ do
  When "I edit medical facility provider data to:", table(%{
      | npi                     | 1234567890       |
      | id_type                 | other            |
      | provider_in_facility_id | 3333333333       |
      | name_prefix             | Mr               |
      | first_name              | John             |
      | middle_name             | X.               |
      | last_name               | Doe              |
      | name_suffix             | Jr               |
      | credentials             | PhD              |
      | email                   | some_new@xxx.com |
      | mobile_phone            | 555-555-5555     |
  })
end

When /^I enter some medical facility nurse data$/ do
  When "I edit medical facility nurse data to:", table(%{
      | npi                  | 1234567890         |
      | id_type              | ssn                |
      | nurse_in_facility_id | 222222222          |
      | name_prefix          | Mr                 |
      | first_name           | John               |
      | middle_name          | X.                 |
      | last_name            | Doe                |
      | name_suffix          | Jr                 |
      | credentials          | PhD                |
      | email                | j113ny.doe@xxx.com |
  })
  And "I check \"Charge Nurse\""
end

When /^I enter some nurse data$/ do
  When "I edit medical facility nurse data to:", table(%{
      | npi                  | 1234567890         |
      | name_prefix          | Mr                 |
      | first_name           | John               |
      | middle_name          | X.                 |
      | last_name            | Doe                |
      | name_suffix          | Jr                 |
      | credentials          | PhD                |
      | email                | j113ny.doe@xxx.com |
  })
  And "I check \"Charge Nurse\""
end


When /^I edit provider group "([^"]*)"$/ do |group_name|
  @provider_group = ProviderGroup.find_by_name(group_name)
  @nested_provider_group = @provider_group
  @location = nil
  When "I click edit icon in summary table \".provider-groups-summary-table\" on row containing \"#{group_name}\""
end

When /^I enter some organization data$/ do
  When "I edit organization data to:", table(%{
      | npi          | 9994567890   |
      | name         | My Group     |
      | address1     | 1 Elm Street |
      | address2     | Suite 3      |
      | zip          | 92345        |
      | phone        | 123-456-7890 |
      | state        | CA           |
      | city         | Santa Clara  |
      | applications | qliq_connect |
  })
end

When /^I click add agent "([^"]*)" as staff$/ do |staff_name|
  When "I click add button inside \".billing-agency-agents\" on result named \"#{staff_name}\""
end

When /^I delete provider group "([^"]*)"$/ do |provider_group_name|
  @provider_group = ProviderGroup.find_by_name(provider_group_name)
  When "I click delete icon in summary table \".provider-groups-summary-table\" on row containing \"#{provider_group_name}\""
end

When /^I enter billing information admin dashboard$/ do
  visit(dashboard_billing_agency_admin_show_dashboard_path)
end

Then /^I should be on group type selection page$/ do
  Then "I should see \"#{dashboard_billing_agency_admin_add_provider_group_path(:location_id => selected_location.id)}\" in the address bar"
end

Then /^new provider group should be created$/ do
  @nested_provider_group = selected_location.provider_groups.where(:name => nil, :group_type => @group_type).first
  @nested_provider_group.should_not be_nil
  @nested_provider_group.provider_group_admin.should == @provider_group_admin
  @provider_group = @nested_provider_group
  @location = nil
end

Then /^I enter some facility data$/ do
  When "I edit facility data to:", table(%{
      | name             | Test Facility 1          |
      | npi              | 1234567890               |
      | it_contact_name  | Frank Fernandez          |
      | it_contact_email | f.fernandez@facility.org |
      | it_contact_phone | 123-456-7893             |
      | address1         | 11 North Park            |
      | address2         | Suite 100                |
      | city             | Los Angeles              |
      | state            | CA                       |
      | zip              | 90210                    |
      | phone            | 997-997-9937             |
  })
end

Then /^I should see provider groups summary:$/ do |table|
  Then "I should see \"#{I18n.t("summary.provider_groups.title")}\""
  should_render_table_content(".provider-groups-summary-table .row", table)
end

Then /^system saves nested group data$/ do
  check_provider_group_attributes(@nested_provider_group.reload)
end

Then /^my nested location should be saved$/ do
  check_location_attributes(@nested_provider_group, false)
end

Then /^it should not be possible to select I am this provider$/ do
  Then "I should not see \"#{I18n.t("providers.is_group_admin")}\""
end

Then /^I should see it is possible to add following agents as staff:$/ do |table|
  should_render_table_content(".billing-agency-agents form", table)
end

Then /^agent "([^"]*)" should be staff in locations "([^"]*)" and "([^"]*)"$/ do |staff_last_name, location1_name, location2_name|
  staff = Staff.find_by_last_name(staff_last_name)
  location1 = Location.find_by_name(location1_name)
  location1.staffs.should include(staff)
  location2 = Location.find_by_name(location2_name)
  location2.staffs.should include(staff)
end

Then /^agent "([^"]*)" should be staff in location "([^"]*)" and facility "([^"]*)"$/ do |staff_last_name, location_name, facility_name|
  staff = Staff.find_by_last_name(staff_last_name)
  location = Location.find_by_name(location_name)
  location.staffs.should include(staff)
  facility = Facility.find_by_name(facility_name)
  facility.staffs.should include(staff)
end

Then /^it should not be possible to edit staff "([^"]*)"$/ do |staff_name|
  expect { When "I edit staff \"#{staff_name}\"" }.to raise_error
end

Then /^it should not be possible to resend confirmation to staff "([^"]*)"$/ do |email|
  expect { When "I click resend confirmation email to \"#{email}\"" }.to raise_error
end

Then /^there should be no staff "([^"]*)" in location "([^"]*)"$/ do |staff_last_name, location_name|
  should_be_no_staff(staff_last_name, Location.find_by_name(location_name))
end

Then /^there should be no staff "([^"]*)" in facility "([^"]*)"$/ do |staff_last_name, facility_name|
  should_be_no_staff(staff_last_name, Facility.find_by_name(facility_name))
end

def should_be_no_staff staff_last_name, staffs_owner
  staffs_owner.staffs.find_by_last_name(staff_last_name).should be_nil
end

Then /^staff "([^"]*)" should still be in location "([^"]*)"$/ do |staff_last_name, location_name|
  Location.find_by_name(location_name).staffs.find_by_last_name(staff_last_name).should_not be_nil
end

Then /^provider group should be deleted$/ do
  active_record_should_be_deleted(@provider_group)
end

Then /^everything that belongs to provider group should be deleted$/ do
  @provider_group.locations.each { |loc| active_record_should_be_deleted(loc) }
  @provider_group.facilities.each { |fac| active_record_should_be_deleted(fac) }
  Admin::ProviderGroupView.find_by_provider_group_id(@provider_group.id).should be_nil
end