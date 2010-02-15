Feature: Read It Later Management
  In order to manage a list of bookmarks from read it later lists,
  I should be able to add, get and mark as read bookmarks.
  
  Scenario: Add a new bookmark
    Given I have a valid API Key and User
    When I create a ReadItLater API Object 
    And I add a new bookmark
    Then I should get back a success response from RIL server
    And I should receive usual user and key limits

  Scenario: Send several updates at once
    Given I have a valid API Key and User
    When I create a ReadItLater API Object 
    And I send several updates
    Then I should get back a success response from RIL server
    And I should receive usual user and key limits

  Scenario: Request statistics of Read It Later bookmarks
    Given I have a valid API Key and User
    When I create a ReadItLater API Object 
    And I send a statistics request
    Then I should get back a success response from RIL server
    And I should receive usual user and key limits
    And I should receive statistics of usage

  Scenario Outline: Get a list of bookmarks from Read It Later
    Given I have a valid API Key and User
    When I create a ReadItLater API Object
    And I send a request for a list of "<count>" "<state>" Read It Later bookmarks for page "<page>", which are "<mine_only>", since "<since>", with tags "<tags>" 
    Then I should get back a success response from RIL server
    And I should receive data about the list of bookmarks
    And I should receive a list of bookmarks, although it can be empty

    Examples:
      | state  | mine_only | since      | count | page | tags  |
      | read   |           |            |       |      |       |
      | unread |           |            |       |      |       |
      |        | true      |            |       |      |       |
      |        | false     |            |       |      |       |
      |        |           | 2000-01-01 |       |      |       |
      |        |           |            | 10    |      |       |
      |        |           |            | 10    | 2    |       |
      |        |           |            |       |      | true  |
      |        |           |            |       |      | false |

  Scenario: Authenticate an existing user
    Given I have a valid API Key and User
    When I create a ReadItLater API Object 
    And I authenticate an existing user
    Then I should get back a success response from RIL server
    And I should receive usual user and key limits

  Scenario:Sign up a new user
    Given I have a valid API Key and User
    When I create a ReadItLater API Object 
    And I sign up a new user
    Then I should get back a success response from RIL server
    And I should receive usual user and key limits

  Scenario: Get bookmark list statistics
    Given I have a valid API Key and User
    When I create a ReadItLater API Object 
    And I send an API bookmarks list statistics request
    Then I should get back a success response from RIL server
    And I should receive usual user and key limits

    

