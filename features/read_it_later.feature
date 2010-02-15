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
    
