Given /^all NPI searches return no results$/ do
  Given "Mocked npi search"
  npi_search_mockers_manager.mock_all_searches_return_no_results
end

When /^I press Edit button$/ do
  find(".important-button", :text => I18n.t("edit")).click
end

When /^I edit my profile information to:$/ do |table|
  @edited_profile_data = table.rows_hash
  ["first_name", "last_name", "credentials"].each do |attr_name|
    unless @edited_profile_data[attr_name].nil?
      When "I fill in \"#{I18n.t(attr_name)}\" with \"#{@edited_profile_data[attr_name]}\""
    end
  end
  ["email", "mobile_phone", "phone"].each do |attr_name|
    unless @edited_profile_data[attr_name].nil?
      When "I fill in \"#{I18n.t("contact_info.#{attr_name}")}\" with \"#{@edited_profile_data[attr_name]}\""
    end
  end
  edit_checkboxes(:locations, :facilities)
end

def edit_checkboxes *collection_names
  @checked = {}
  [:user_roles, :locations, :facilities].each do |collection_sym|
    unless @edited_profile_data[collection_sym.to_s].nil?
      currently_checked = @resource.send(collection_sym).map { |collection_item| collection_item.name }
      @checked[collection_sym] = split_csv(@edited_profile_data[collection_sym.to_s])
      to_uncheck = currently_checked - @checked[collection_sym]
      to_uncheck.each do |name|
        When "I uncheck \"#{name}\""
      end
      @checked[collection_sym].each do |name|
        When "I check \"#{name}\""
      end
    end
  end
end

When /^I press Change password button$/ do
  When "I press \"#{I18n.t("change_password")}\""
end

When /^I change my password from "([^"]*)" to "([^"]*)"$/ do |current_password, new_password|
  When "I fill in \"#{I18n.t("current_password")}\" with \"#{current_password}\""
  And "I fill in \"#{I18n.t("new_password")}\" with \"#{new_password}\""
  And "I fill in \"#{I18n.t("confirm_password")}\" with \"#{new_password}\""
end

Then /^I should see my (.+) list$/ do |resource|
  collection_sym = resource.to_sym
  if @resource.respond_to?(collection_sym)
    @resource.send(collection_sym).each do |el|
      Then "I should see \"#{el.name}\""
    end
  end
end

Then /^I should see link to edit my profile$/ do
  Then "I should see \"#{I18n.t("edit")}\" link"
end

Then /^I should see link to support$/ do
  Then "I should see \"#{:click_here}\" link"
end

Then /^I should see Save and Cancel buttons$/ do
  Then "I should see \"#{I18n.t("save")}\" button"
  Then "I should see \"#{I18n.t("cancel")}\" link"
end

def should_see_edited *field_names
  field_names.to_a.each do |field_name|
    Then "I should see \"#{@edited_profile_data[field_name]}\""
  end
end

def should_see_checked *collections
  collections.to_a.each do |collection_sym|
    @checked[collection_sym].each do |item_name|
      Then "I should see \"#{item_name}\""
    end
  end
end

Then /^I should be on Group information page$/ do
  origin = @resource.user.origin
  show_group_path = @resource.user.provider? ? send("dashboard_#{origin}_provider_show_group_path") : send("dashboard_#{origin}_staff_show_group_path")
  Then "I should be on \"#{show_group_path}\""
end

Then /^my password should be "([^"]*)"$/ do |password|
  @resource.reload
  password_should_be_valid(@resource.user, password)
end

Then /^I should see my password was changed$/ do
  Then "I should see \"#{I18n.t("password_changed")}\""
end
