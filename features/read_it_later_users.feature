Feature: ReadItLater User Management
  In order to make requests to ReadItLaterList.com API
  Library user should be able to create User objects.

  Scenario: User object created with both a user name and a password
    When I create a User object with a user name "sample" and password "mypassword"
    Then I should get a User object with no errors
    And The User object should have a "user name" of "sample"
    And The User object should have a "password" of "mypassword"

  Scenario: User object created with a user name only
    When I create a User object with a user name "sample" and password "unspecified"
    Then I should get a User object with no errors
    And The User object should have a "user name" of "sample"
    And The User object should have a "password" of "unspecified"

  Scenario: User object created without a user name or password
    When I create a User object with a user name "unspecified" and password "unspecified"
    Then I should get a User object with no errors
    And The User object should have a "user name" of "unspecified"
    And The User object should have a "password" of "unspecified"



