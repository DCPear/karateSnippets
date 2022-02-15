@ignore
@project:ERP @story:SplunkSearch @Level:search @endpoint:Splunk
Feature: Search a given event - reusable feature
  Background:

  Scenario:
    # inputs params from caller
    * print searchTerm
    * print searchResponseTerm
    * print epoch

    # Set search event in splunkSearchReq.json
    * def searchReq = read("classpath:utilities/splunk/splunkSearchReq.json")
    * set searchReq.search = searchTerm
    * set searchReq.earliest_time = epoch
    * Java.type("java.lang.Thread").sleep(10000)

    # # Call search event at given time period
    * def search = call read("classpath:utilities/splunk/splunkSearch.feature")

    # return response to the caller
    *  xml responseXml = search.response
    *  print responseXml
    * def result =  karate.xmlPath(search.response, searchResponseTerm)
