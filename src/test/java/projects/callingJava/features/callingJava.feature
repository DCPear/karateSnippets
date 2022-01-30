Feature:  Calling java methods


  Background:
    * def stringUtils = Java.type("utilities.common.StringUtils")

  Scenario: calling java
    * def result = stringUtils.bodyis('Mr' , '{firstName:Jonas lastName:Smith}', 4567)
    * print "body is: ", result
