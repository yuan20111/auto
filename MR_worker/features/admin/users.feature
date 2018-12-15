@admin
Feature: Admin Users
  Background:
    Given I sign in as an admin
    And system has users

  Scenario: On Admin Users
    Given I visit admin users page
    Then I should see all users

  Scenario: Edit user and change username to non ascii char
    When I visit admin users page
    And Click edit
    And Input non ascii char in username
    And Click save
    Then See username error message
    And Not changed form action url

  Scenario: Show user attributes
    Given user "Mike" with groups and projects
    Given I visit admin users page
    And click on "Mike" link
    Then I should see user "Mike" details

  Scenario: Edit my user attributes
    Given I visit admin users page
    And click edit on my user
    When I submit modified user
    Then I see user attributes changed

@javascript
  Scenario: Remove users secondary email
    Given I visit admin users page
    And I view the user with secondary email
    And I see the secondary email
    When I click remove secondary email
    Then I should not see secondary email anymore

  Scenario: Show user keys
    Given user "Pete" with ssh keys
    And I visit admin users page
    And click on user "Pete"
    Then I should see key list
    And I click on the key title
    Then I should see key details
    And I click on remove key
    Then I should see the key removed
