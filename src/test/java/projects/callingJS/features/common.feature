@ignore
Feature: Common Functions

  Scenario: Define something to be used elsewhere
    * def greeter = function(name){ return 'Hello ' + name.first + ' ' + name.last + '!' }

    * def now = function(){ return java.lang.System.currentTimeMillis() }

    * def uuid = function(){ return java.util.UUID.randomUUID() + '' }