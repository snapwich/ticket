Feature: Ticket Plan (Dependency Resolution Order)
  As a user
  I want to see the dependency resolution order by wave
  So that I can understand the full execution order of my backlog

  Background:
    Given a clean tickets directory

  Scenario: Single ticket with no deps shows one wave
    Given a ticket exists with ID "task-0001" and title "Solo task"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Wave 1"
    And the output should contain "task-0001"
    And the output should contain "Solo task"

  Scenario: All ready tickets appear in wave 1
    Given a ticket exists with ID "task-0001" and title "First task"
    And a ticket exists with ID "task-0002" and title "Second task"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Wave 1"
    And the output should contain "task-0001"
    And the output should contain "task-0002"
    And the output should not contain "Wave 2"

  Scenario: Linear chain produces sequential waves
    Given a ticket exists with ID "task-0001" and title "Foundation"
    And a ticket exists with ID "task-0002" and title "Middle layer"
    And a ticket exists with ID "task-0003" and title "Top layer"
    And ticket "task-0002" depends on "task-0001"
    And ticket "task-0003" depends on "task-0002"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Wave 1"
    And the output should contain "Wave 2"
    And the output should contain "Wave 3"
    And the plan wave 1 should contain "task-0001"
    And the plan wave 2 should contain "task-0002"
    And the plan wave 3 should contain "task-0003"

  Scenario: Multiple roots with dependents
    Given a ticket exists with ID "task-0001" and title "Auth endpoint"
    And a ticket exists with ID "task-0002" and title "Landing page"
    And a ticket exists with ID "task-0003" and title "Auth middleware"
    And ticket "task-0003" depends on "task-0001"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Wave 1"
    And the output should contain "Wave 2"
    And the output should contain "task-0001"
    And the output should contain "task-0002"
    And the output should contain "task-0003"

  Scenario: Multi-dep ticket waits for all deps
    Given a ticket exists with ID "task-0001" and title "Auth endpoint"
    And a ticket exists with ID "task-0002" and title "User model"
    And a ticket exists with ID "task-0003" and title "Integration tests"
    And ticket "task-0003" depends on "task-0001"
    And ticket "task-0003" depends on "task-0002"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Wave 1"
    And the output should contain "Wave 2"
    And the plan wave 1 should contain "task-0001"
    And the plan wave 1 should contain "task-0002"
    And the plan wave 2 should contain "task-0003"

  Scenario: Blocker annotations show resolved deps
    Given a ticket exists with ID "task-0001" and title "Auth endpoint"
    And a ticket exists with ID "task-0002" and title "Auth middleware"
    And ticket "task-0002" depends on "task-0001"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "<- [task-0001]"

  Scenario: Wave 1 tickets have no blocker annotations
    Given a ticket exists with ID "task-0001" and title "Ready task"
    When I run "ticket plan"
    Then the command should succeed
    And the output should not contain "<-"

  Scenario: Cycles shown in blocked section
    Given a ticket exists with ID "task-0001" and title "Circular A"
    And a ticket exists with ID "task-0002" and title "Circular B"
    And ticket "task-0001" depends on "task-0002"
    And ticket "task-0002" depends on "task-0001"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Blocked (cycle or missing dep):"
    And the output should contain "task-0001"
    And the output should contain "task-0002"

  Scenario: Mixed waves and blocked tickets
    Given a ticket exists with ID "task-0001" and title "Ready task"
    And a ticket exists with ID "task-0002" and title "Depends on ready"
    And a ticket exists with ID "task-0003" and title "Circular A"
    And a ticket exists with ID "task-0004" and title "Circular B"
    And ticket "task-0002" depends on "task-0001"
    And ticket "task-0003" depends on "task-0004"
    And ticket "task-0004" depends on "task-0003"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Wave 1"
    And the output should contain "Wave 2"
    And the output should contain "Blocked (cycle or missing dep):"

  Scenario: Closed tickets are excluded
    Given a ticket exists with ID "task-0001" and title "Done task"
    And a ticket exists with ID "task-0002" and title "Open task"
    And ticket "task-0001" has status "closed"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "task-0002"
    And the output should not contain "task-0001"

  Scenario: Closed deps count as resolved
    Given a ticket exists with ID "task-0001" and title "Done dep"
    And a ticket exists with ID "task-0002" and title "Depends on done"
    And ticket "task-0001" has status "closed"
    And ticket "task-0002" depends on "task-0001"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "Wave 1"
    And the output should contain "task-0002"
    And the output should not contain "task-0001"

  Scenario: Priority sorting within waves
    Given a ticket exists with ID "task-0001" and title "Low prio" with priority 3
    And a ticket exists with ID "task-0002" and title "High prio" with priority 0
    And a ticket exists with ID "task-0003" and title "Med prio" with priority 1
    When I run "ticket plan"
    Then the command should succeed
    And the tree output should have task-0002 before task-0003
    And the tree output should have task-0003 before task-0001

  Scenario: Status filter
    Given a ticket exists with ID "task-0001" and title "Open task"
    And a ticket exists with ID "task-0002" and title "In progress task"
    And ticket "task-0002" has status "in_progress"
    When I run "ticket plan --status=open"
    Then the command should succeed
    And the output should contain "task-0001"
    And the output should not contain "task-0002"

  Scenario: Assignee filter
    Given a ticket exists with ID "task-0001" and title "Alice task"
    And a ticket exists with ID "task-0002" and title "Bob task"
    And ticket "task-0001" has assignee "alice"
    And ticket "task-0002" has assignee "bob"
    When I run "ticket plan -a alice"
    Then the command should succeed
    And the output should contain "task-0001"
    And the output should not contain "task-0002"

  Scenario: Tag filter
    Given a ticket exists with ID "task-0001" and title "Backend task"
    And a ticket exists with ID "task-0002" and title "Frontend task"
    And ticket "task-0001" has tags "backend"
    And ticket "task-0002" has tags "frontend"
    When I run "ticket plan -T backend"
    Then the command should succeed
    And the output should contain "task-0001"
    And the output should not contain "task-0002"

  Scenario: No active tickets produces no output
    Given a ticket exists with ID "task-0001" and title "Done task"
    And ticket "task-0001" has status "closed"
    When I run "ticket plan"
    Then the command should succeed
    And the output should be empty

  Scenario: Diamond dependency pattern
    Given a ticket exists with ID "task-0001" and title "Root"
    And a ticket exists with ID "task-0002" and title "Left branch"
    And a ticket exists with ID "task-0003" and title "Right branch"
    And a ticket exists with ID "task-0004" and title "Merge point"
    And ticket "task-0002" depends on "task-0001"
    And ticket "task-0003" depends on "task-0001"
    And ticket "task-0004" depends on "task-0002"
    And ticket "task-0004" depends on "task-0003"
    When I run "ticket plan"
    Then the command should succeed
    And the plan wave 1 should contain "task-0001"
    And the plan wave 2 should contain "task-0002"
    And the plan wave 2 should contain "task-0003"
    And the plan wave 3 should contain "task-0004"

  Scenario: Shows priority, status, and type in output
    Given a ticket exists with ID "task-0001" and title "My task" with priority 1
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "[P1]"
    And the output should contain "[open]"
    And the output should contain "[task]"

  Scenario: In-progress tickets included by default
    Given a ticket exists with ID "task-0001" and title "WIP task"
    And ticket "task-0001" has status "in_progress"
    When I run "ticket plan"
    Then the command should succeed
    And the output should contain "task-0001"
    And the output should contain "[in_progress]"
