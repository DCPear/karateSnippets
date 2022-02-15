Feature: matching

  @test-01-convert
  Scenario: convert string number to int number
    * def suffix = ""
    * def requestFile = "R12_Extract_20220202.csv"
    * def req = suffix ? (requestFile + suffix): requestFile
    * print req