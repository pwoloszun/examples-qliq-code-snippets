Feature: Billing agency admin dashboard
  As a billing agency admin
  I want to be able to:
  - see/add/edit agents and provider groups
  - edit my profile
  - go back to billing agency setup
  So that my account is fully configurable and users in my agency can use the system.

  Background:
    Given all NPI searches return no results
    And taxonomy table contains some data
    Given There are following provider groups in the system:
      | npi        | name    | group_type     | address1        | address2 | city      | state | zip   | phone        | user_email                 | user_pass | user_first_name | user_last_name |
      | 1234567890 | Group 1 | billing_agency | 100 West Street |          | San Diego | CA    | 90210 | 222-222-2222 | bruce.wayne@groupadmin.com | 123456    | Bruce           | Wayne          |
    And group "Group 1" setup has been successfully finished
    And "Group 1" contains following locations:
      | name       | address1            | address2 | city        | state | zip   | phone        |
      | Location 1 | 11 West Main Street | Suite 1  | New York    | NY    | 27510 | 555-555-5555 |
      | Location 2 | 12 West Main Street | Suite 2  | Los Angeles | CA    | 90210 | 555-555-5555 |
      | Location 3 | 13 West Main Street | Suite 3  | Los Angeles | CA    | 90210 | 555-555-5555 |
    And location "Location 1" contains following staff:
      | first_name | last_name | email                     | roles               |
      | Walt       | Frazier   | walt.frazier@staff.com    | Scheduling, Billing |
      | Hakeem     | Olajuwon  | hakeem.olajuwon@staff.com | Billing             |
    And location "Location 3" contains following staff:
      | first_name | last_name | email                 | roles      |
      | Harry      | Potter    | harry.poter@staff.com | Scheduling |
    And location "Location 1" contains following provider groups:
      | npi        | name    | group_type              | address1         | address2 | city          | state | zip   | phone        |
      | 1234567891 | Group 2 | multi_provider_practice | 100 West Street  |          | San Diego     | CA    | 90210 | 222-222-2222 |
      | 1234567892 | Group 3 | medical_facility        | 100 South Street |          | San Fransisco | CA    | 90001 | 111-222-2222 |
    And "Group 2" contains following locations:
      | name       | address1            | address2 | city     | state | zip   | phone        |
      | Location 4 | 11 West Main Street | Suite 1  | New York | NY    | 27510 | 555-555-5555 |
    And location "Location 4" contains following providers:
      | first_name | last_name | credentials | taxonomy_code | npi        | email                         | mobile_phone |
      | Auguste    | Beeneart  | MD          | 1             | 9876546666 | auguste.beeneart@provider.com | 555-555-5555 |
    And "Group 3" contains following facilities:
      | name       | taxonomy_code | address1            | address2 | city     | state | zip   | phone_number | npi        | it_contact_name | npi_registry_address_id |
      | Facility 1 | 4             | 10 West Main Street | Suite 1  | New York | NY    | 27510 | 555-555-5555 | 1111111111 | Frank X         | a                       |
    And facility "Facility 1" contains following providers:
      | provider_in_facility_id | name_prefix | first_name | middle_name | last_name | name_suffix | credentials | taxonomy_code | npi        | email            | mobile_phone |
      | 1234567891              |             | Frederic   |             | Passy     |             | MD          | 1             | 1239482211 | x2345x2@test.com | 555-555-5555 |
    And I sign in as "bruce.wayne@groupadmin.com" with password "123456"

  Scenario: Logging to the system
    Then I should be on "Location 1" billing agency dashboard screen
    And I should see current location information
    And I should see agents summary:
      | name            | role 1  | role 2     | email                     |
      | Walt Frazier    | Billing | Scheduling | walt.frazier@staff.com    |
      | Hakeem Olajuwon | Billing |            | hakeem.olajuwon@staff.com |
    And I should see provider groups summary:
      | name    | npi        | group_type              |
      | Group 2 | 1234567891 | Multi-provider practice |
      | Group 3 | 1234567892 | Medical facility        |
    And my login activity should be saved
    And I should see my group information

  Scenario: Editing agent
    When I edit agent "Olajuwon"
    Then I should be on edit agent page
    When I press save button
    Then I should be on "Location 1" billing agency dashboard screen

  Scenario: Editing agent - back button
    When I edit agent "Olajuwon"
    Then I should be on edit agent page
    When I press back button
    Then I should be on "Location 1" billing agency dashboard screen

  Scenario: Adding provider practice group
    When I press add provider group button
    Then I should be on group type selection page
    When I select "solo_practice" group as group type
    And I press create new provider group button
    Then new provider group should be created
    And I should be on provider group step of provider practice wizard
    When I click enter provider group data manually
    Then I should be on edit provider group page
    When I enter some provider group data
    And I press save button
    Then system saves nested group data
    And I should be on locations step of provider practice setup wizard
    When I add not searched location
    And I enter some location data
    And I press create new button
    Then my nested location should be saved
    When I press next step button
    Then I should be on facilities step of provider practice setup wizard
    When I add not searched facility
    And I enter some facility data
    And I press create new button
    Then my facility should be saved
    When I press next step button
    Then I should be on providers step of provider practice setup wizard
    When I add not searched provider
    And I enter some provider data
    And I press create new button
    Then my provider should be saved
    When I press next step button
    Then I should be on new staff page
    When I enter some staff data
    And I press create new button
    Then staff should be saved
    When I press next step button
    Then I should be on nurses step of provider practice setup wizard
    When I add not searched nurse
    And I enter some nurse data
    And I press create new button
    Then my provider practice setup nurse should be saved
    When I press next step button
    Then I should be on referring providers step of provider practice setup wizard
    When I press next step button
    Then I should be on billing information step
    When I enter my credit card information
    And press process payment
    Then I should be on business agreement screen
    When I click skip agreement
    Then I should be on congratulations page
    When I follow "Go to Dashboard"
    Then I should be on "Location 1" billing agency dashboard screen

  Scenario: Editing provider practice group
    When I edit provider group "Group 3"
    Then I should be on organization step
    When I click enter organization data manually
    When I enter some organization data
    And I press save button
    Then system saves nested group data
    And I should be on facilities step of medical facility setup
    When I add not searched facility
    And I enter some facility data
    And I press create new button
    Then my medical facility setup facility should be saved
    When I press next step button
    Then I should be on providers step of medical facility setup wizard
    When I select facility "F1" tab
    And I press add medical provider
    And I add not searched provider
    And I enter some medical facility provider data
    And I press create new button
    Then my medical facility setup provider should be saved
    When I press next step button
    Then I should be on new staff page of medical facility setup wizard
    When I enter some staff data
    And I press create new button
    Then medical facility staff should be saved
    When I press next step button
    Then I should be on nurses step of medical facility setup wizard
    When I add not searched nurse
    And I enter some medical facility nurse data
    And I press create new button
    Then my medical facility setup nurse should be saved
    When I press next step button
    Then I should be on billing information step of medical facility setup wizard
    When I enter my credit card information
    And press process payment
    Then I should be on business agreement screen of medical facility setup wizard
    When I click skip agreement
    Then I should be on congratulations page of medical facility setup wizard
    When I follow "Go to Dashboard"
    Then I should be on "Location 1" billing agency dashboard screen

  Scenario: Adding provider group to second location
    When I select location "Location 2" tab
    And I press add provider group button
    When I select "solo_practice" group as group type
    And I press create new provider group button
    Then I should be on provider group step of provider practice wizard

  Scenario: Using back button in nested setup
    When I edit provider group "Group 3"
    Then I should be on organization step
    When I follow Back Button in context menu
    Then I should be on "Location 1" billing agency dashboard screen

  Scenario: I am this provider checkbox should not be available
    When I edit provider group "Group 2"
    And I click enter provider group data manually
    And I enter some provider group data
    And I press save button
    And I add not searched location
    And I enter some location data
    And I press create new button
    And I press next step button 2 times
    Then I should be on providers step of provider practice setup wizard
    When I add not searched provider
    Then I should be on create new provider page
    And it should not be possible to select I am this provider

  Scenario: Adding agents as staff in practice location setup
    When I edit provider group "Group 2"
    And I enter staff step
    Then all staff fields should be empty
    And I should see it is possible to add following agents as staff:
      | first_name | last_name | email                     | roles               |
      | Walt       | Frazier   | walt.frazier@staff.com    | Billing, Scheduling |
      | Hakeem     | Olajuwon  | hakeem.olajuwon@staff.com | Billing             |
      | Harry      | Potter    | harry.poter@staff.com     | Scheduling          |
    When I click add agent "Frazier" as staff
    Then I should be on staff summary
    And agent "Frazier" should be staff in locations "Location 1" and "Location 4"
    When I press add staff button
    Then I should be on new staff page
    And I should see it is possible to add following agents as staff:
      | first_name | last_name | email                     | roles               |
      | Walt       | Frazier   | walt.frazier@staff.com    | Billing, Scheduling |
      | Hakeem     | Olajuwon  | hakeem.olajuwon@staff.com | Billing             |
      | Harry      | Potter    | harry.poter@staff.com     | Scheduling          |
    When I click add agent "Frazier" as staff
    Then I should be on staff summary
    And I should see staff summary:
      | first_name | last_name | email                  | roles              |
      | Walt       | Frazier   | walt.frazier@staff.com | Billing Scheduling |
    And it should not be possible to edit staff "Frazier"
    And it should not be possible to resend confirmation to staff "walt.frazier@staff.com"

  Scenario: Adding agents as staff in medical facility setup
    When I edit provider group "Group 3"
    And I enter staff step of medical facility setup wizard
    Then all staff fields should be empty
    And I should see it is possible to add following agents as staff:
      | first_name | last_name | email                     | roles               |
      | Walt       | Frazier   | walt.frazier@staff.com    | Billing, Scheduling |
      | Hakeem     | Olajuwon  | hakeem.olajuwon@staff.com | Billing             |
      | Harry      | Potter    | harry.poter@staff.com     | Scheduling          |
    When I click add agent "Frazier" as staff
    Then I should be on staff summary of medical facility setup wizard
    And agent "Frazier" should be staff in location "Location 1" and facility "Facility 1"

  Scenario: Deleting agent who is staff in medical facility
    Given facility "Facility 1" contains staff "Frazier"
    When I enter agents step of billing agency setup wizard
    And I delete agent "Frazier"
    Then there should be no staff "Frazier" in location "Location 1"
    And there should be no staff "Frazier" in facility "Facility 1"

  Scenario: Deleting staff who is agent from medical facility
    Given facility "Facility 1" contains staff "Frazier"
    When I edit provider group "Group 3"
    And I enter staff step of medical facility setup wizard
    And I delete medical facility staff "Frazier"
    Then staff "Frazier" should still be in location "Location 1"
    And there should be no staff "Frazier" in facility "Facility 1"

  Scenario: Deleting staff who is agent from provider practice
    Given location "Location 4" contains staff "Frazier"
    When I edit provider group "Group 2"
    And I enter staff step
    And I delete staff "Frazier"
    Then staff "Frazier" should still be in location "Location 1"
    And there should be no staff "Frazier" in location "Location 4"

  Scenario: Deleting location that has an agent
    Given location "Location 4" contains staff "Frazier"
    When I edit provider group "Group 2"
    And I enter locations step
    And I select location "Location 4" tab
    And I press delete
    Then staff "Frazier" should still be in location "Location 1"

  Scenario: Using Invoice Billing Agency as a payment method
    Given "Invoice Group" payment method requires at least "10" providers
    When I edit provider group "Group 2"
    And I enter billing information step
    Then I can choose "Invoice Billing Agency" as payment method
    And I can choose "Invoice Group" as payment method
    When I choose "Invoice Billing Agency"
    And I press save billing information button
    Then my billing information should be saved
    And I should be on business agreement screen

  Scenario: Deleting provider group
    When I delete provider group "Group 2"
    Then provider group should be deleted
    And everything that belongs to provider group should be deleted
    When I delete provider group "Group 3"
    Then provider group should be deleted
    And everything that belongs to provider group should be deleted

  Scenario: Displaying provider groups of agents
    Given location "Location 4" contains staff "Frazier"
    And facility "Facility 1" contains staff "Frazier"
    And location "Location 4" contains staff "Potter"
    When I enter billing information admin dashboard
    And I should see agents summary:
      | name            | role 1  | role 2     | email                     | provider_group1 | provider_group2 |
      | Walt Frazier    | Billing | Scheduling | walt.frazier@staff.com    | Group 2         | Group 3         |
      | Hakeem Olajuwon | Billing |            | hakeem.olajuwon@staff.com |                 |                 |
    When I select location "Location 3" tab
    Then I should see agents summary:
      | first_name | last_name | email                 | role       | provider_group |
      | Harry      | Potter    | harry.poter@staff.com | Scheduling | Group 2        |

  @javascript
  Scenario: Locking account
    When I edit provider group "Group 2"
    And I enter providers step
    And I lock user "auguste.beeneart@provider.com" device
    Then I should be on providers step of provider practice setup wizard
    And user "auguste.beeneart@provider.com" should have locked device

