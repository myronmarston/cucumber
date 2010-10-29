Feature: Around hooks

  @wip @announce
  Scenario: Mixing Around, Before, and After hooks
    Given a file named "features/step_definitions/steps.rb" with:
      """
      $sequence_order = []

      Given /^we have a background step$/ do
        $sequence_order << 'Background' unless $sequence_order.include?('Background')
      end

      When /^the scenario step runs$/ do
        $sequence_order << 'Scenario'
      end

      Then /^the hooks and steps should have run in the expected order$/ do
        $sequence_order.should == [
          'Around Before',
          'Before',
          'Background',
          'Scenario',
          'After',
          'Around After'
        ]
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Around('@main') do |scenario, block|
        $sequence_order << 'Around Before'
        block.call
        $sequence_order << 'Around After'
      end

      Before('@main') do |scenario|
        $sequence_order << 'Before'
      end

      After('@main') do |scenario|
        $sequence_order << 'After'
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Around hooks
        Background:
          Given we have a background step

        @main
        Scenario: Mixing Around, Before, and After hooks
          When the scenario step runs

        Scenario: Check sequence result
          Then the hooks and steps should have run in the expected order
      """
    When I run "cucumber features/f.feature"
    Then it should pass with:
      """
      Feature: Around hooks

        Background:                       # features/f.feature:2
          Given we have a background step # features/step_definitions/steps.rb:3

        @main
        Scenario: Mixing Around, Before, and After hooks # features/f.feature:6
          When the scenario step runs                    # features/step_definitions/steps.rb:7

        Scenario: Check sequence result                                  # features/f.feature:9
          Then the hooks and steps should have run in the expected order # features/step_definitions/steps.rb:11

      2 scenarios (2 passed)
      4 steps (4 passed)

      """

