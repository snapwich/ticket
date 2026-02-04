Feature: Ticket Status Management
  As a user
  I want to change ticket statuses
  So that I can track progress on tasks

  Background:
    Given a clean tickets directory
    And a ticket exists with ID "test-0001" and title "Test ticket"

  Scenario: Set status to in_progress
    When I run "ticket status test-0001 in_progress"
    Then the command should succeed
    And the output should be "Updated test-0001 -> in_progress"
    And ticket "test-0001" should have field "status" with value "in_progress"

  Scenario: Set status to closed
    When I run "ticket status test-0001 closed"
    Then the command should succeed
    And the output should be "Updated test-0001 -> closed"
    And ticket "test-0001" should have field "status" with value "closed"

  Scenario: Set status to open
    Given ticket "test-0001" has status "closed"
    When I run "ticket status test-0001 open"
    Then the command should succeed
    And the output should be "Updated test-0001 -> open"
    And ticket "test-0001" should have field "status" with value "open"

  Scenario: Start command sets status to in_progress
    When I run "ticket start test-0001"
    Then the command should succeed
    And the output should be "Updated test-0001 -> in_progress"
    And ticket "test-0001" should have field "status" with value "in_progress"

  Scenario: Close command sets status to closed
    When I run "ticket close test-0001"
    Then the command should succeed
    And the output should be "Updated test-0001 -> closed"
    And ticket "test-0001" should have field "status" with value "closed"

  Scenario: Reopen command sets status to open
    Given ticket "test-0001" has status "closed"
    When I run "ticket reopen test-0001"
    Then the command should succeed
    And the output should be "Updated test-0001 -> open"
    And ticket "test-0001" should have field "status" with value "open"

  Scenario: Invalid status value
    When I run "ticket status test-0001 invalid"
    Then the command should fail
    And the output should contain "Error: invalid status 'invalid'"
    And the output should contain "open in_progress closed"

  Scenario: Status of non-existent ticket
    When I run "ticket status nonexistent open"
    Then the command should fail
    And the output should contain "Error: ticket 'nonexistent' not found"

  Scenario: Status command with partial ID
    When I run "ticket status 0001 in_progress"
    Then the command should succeed
    And ticket "test-0001" should have field "status" with value "in_progress"

  Scenario: Assign command sets assignee
    When I run "ticket assign test-0001 worker"
    Then the command should succeed
    And the output should be "Assigned test-0001 -> worker"
    And ticket "test-0001" should have field "assignee" with value "worker"

  Scenario: Assign command updates existing assignee
    Given ticket "test-0001" has assignee "old-worker"
    When I run "ticket assign test-0001 new-worker"
    Then the command should succeed
    And the output should be "Assigned test-0001 -> new-worker"
    And ticket "test-0001" should have field "assignee" with value "new-worker"

  Scenario: Assign command with partial ID
    When I run "ticket assign 0001 qa-agent"
    Then the command should succeed
    And ticket "test-0001" should have field "assignee" with value "qa-agent"

  Scenario: Assign non-existent ticket fails
    When I run "ticket assign nonexistent worker"
    Then the command should fail
    And the output should contain "Error: ticket 'nonexistent' not found"

  Scenario: Unassign command clears assignee
    Given ticket "test-0001" has assignee "worker"
    When I run "ticket unassign test-0001"
    Then the command should succeed
    And the output should be "Unassigned test-0001"
    And ticket "test-0001" should not have field "assignee"

  Scenario: Unassign ticket without assignee succeeds
    When I run "ticket unassign test-0001"
    Then the command should succeed
    And the output should be "Ticket test-0001 has no assignee"

  Scenario: Unassign command with partial ID
    Given ticket "test-0001" has assignee "worker"
    When I run "ticket unassign 0001"
    Then the command should succeed
    And ticket "test-0001" should not have field "assignee"

  Scenario: Unassign non-existent ticket fails
    When I run "ticket unassign nonexistent"
    Then the command should fail
    And the output should contain "Error: ticket 'nonexistent' not found"
