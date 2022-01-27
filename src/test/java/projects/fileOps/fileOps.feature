Feature: file operations

  Background:
    * def textPath = "classpath:projects/fileOps/resources/test.txt"
    * def csvPath = "classpath:projects/fileOps/resources/test.csv"
    * def filePath = "file:projects/fileOps/resources/test.csv"
    * def ddt_data = "classpath:projects/fileOps/resources/test.json"
    * def schemas =
"""
{
  v1: { firstName: "#string", lastName: "#string" },
  v2: { firstName: "#string", lastName: "#string", username: "#string", email: "#string"  }
}
"""

  @test-01-reading-text
  Scenario: reading a text file
    * def testData = read(textPath)
    * print "=== printing data from txt",testData

  @test-02-reading-csv
  Scenario: reading a csv file - (karate automatically convert csv to json)
    * def testData = read(csvPath)
    * print "=== printing data from csv",  testData
    * print "=== Number arrays in the json response",  testData.length

    # check if array is present
    And assert testData != null
    # check array length
    And assert testData.length == 3
    And assert testData.length != 1

    # match
    * match testData[1].firstName == "Steve"
    * match each testData[*].email == "#present"

  @test-03-reading-csv
  Scenario Outline: reading from a csv file and print from each line
    * def testData = read(csvPath)
    * print "=== printing test case elements:", <testCase>
    * print <testCase>[0].firstName
    * print <testCase>[1].lastName
    * print <testCase>[1].username
    * print <testCase>[2].email
    Examples:
      | testCase |
      | testData |

  @test-04-reading-csv
  Scenario: trying  file: prefix, instead of classpath: it supports absolute or even relative paths from current working directory.
    * def testData = read(csvPath)
    * print "=== printing data from csv using file:",  testData

  @test-05-reading-csv
  Scenario Outline: DDT feed from json - print firstName from each test case
    * def testData = read(ddt_data)
    * print "=== printing data traverse thru the Examples table:", <testCase>.firstName

    Examples:
      | testCase             |
      | testData.testCase_01 |
      | testData.testCase_02 |
      | testData.testCase_03 |

  @test-06-reading-csv-and-match
  Scenario: best-way-to-do-karate-match-using-and-contains-using-generic-script
    * def env = 'v1'
    * def response = { "firstName": "Mike",  "lastName": "Pos"}
    * match response contains karate.filterKeys(schemas[env], response)

    * def response = { "firstName": "Mike",  "lastName": "Pos",  "username": "Posner",  "email": "mike1234@gmail.com"}
    * match response contains karate.filterKeys(schemas[env], response)

    * def env = 'v2'
    * def response = { "firstName": "Mike",  "lastName": "Pos"}
    * match response contains karate.filterKeys(schemas[env], response)

    * def response = { "firstName": "Mike",  "lastName": "Pos",  "username": "Posner",  "email": "mike1234@gmail.com"}
    * match response contains karate.filterKeys(schemas[env], response)

    # match each record
    * def response = read(csvPath)
    * match response[0] contains karate.filterKeys(schemas[env], response)
    * match each response[*] contains karate.filterKeys(schemas[env], response)