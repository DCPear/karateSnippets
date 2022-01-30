Feature: JS function argument rules for call

  Background:

    * callonce read("common.feature")

    * def getDate =
  """
  function() {
    var DateTimeFormatter = Java.type('java.time.format.DateTimeFormatter');
    var dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm:ss");
    var ldt = java.time.LocalDateTime.now();
    return ldt.format(dtf);
  }
  """

    * def timeStamp = function(){return Math.floor(Date.now())}

    * def isValidUTC = function(uTCdate){return /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(uTCdate)}

    * def randomPhoneString = function() { var rand = Math.random(); return Math.floor(rand * 100000000) + '' }



  Scenario: call date functions

    * print timeStamp

    * def temp = getDate()
    * print temp

    * def check = call isValidUTC  temp
    * print check

    * def temp = randomPhoneString()
    * print temp

    # from common feature
    *  print  "current time in millis", now()
    *  print "randon UUID", uuid()

  Scenario: Call JavaScript function defined in another feature file
    * def name1 =  call greeter {first: "John", last: "Doe"}
    * print name1

  Scenario: Call JavaScript function defined in another feature file a second time
    * def name2 = call greeter {first: "Jane", last: "Doe"}
    * print name2

    # Reading: https://www.baeldung.com/java-datetimeformatter
  # https://www.dariawan.com/tutorials/java/java-datetimeformatter-tutorial-examples/ (write java for this)
  # https://medium.com/@babusekaran/organizing-re-usable-functions-karatedsl-575cd76daa27
    # Reading: https://github.com/karatelabs/karate#js-function-argument-rules-for-call