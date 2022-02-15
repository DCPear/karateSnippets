@project:SFTPTemplete @story:TransferFile @Level:SFTP @endpoint:source @endpoint:target
Feature: This feature file tests a SFTP transfer between two endpoints. drop a file at source end and inspect the file from target end.

  Background:
    * def nowTime = Java.type("java.time.ZonedDateTime").now().minusHours(24)
    * def epoch = nowTime.toEpochSecond()

  Scenario:

     # Search criteria -
    * def username = user
    * def password = pwd

    # define search criteria - correlation id (request file name) and APIM request URL .
    * text searchTerm =
    """
    search index=openshift "<feature>" |  spath "message.RequestURL" | search "message.RequestURL"="<requestUrl>"
    """

    # set search criteria values
    * def feature = "MFP_INV_20220210_201150.txt"
    * def requestUrl = "https://accinternalapimgmtdev.ds.acc.co.nz/d01/ERP-AxwayFileOperations/V1/files/to_WESTPAC_DEV_MFP_E63/ACC_PPG_DC_D20220210_T201150?transferMode=BINARY"
    * def searchResponseTerm = "/results/result/field[@k='message.CorrelationID']/value/text"
    * replace searchTerm.feature = feature
    * replace searchTerm.requestUrl = requestUrl
    * print searchTerm

    # log in to Splunk
    * call read("classpath:utilities/splunk/splunkLogin.feature")

    # call this feature to search an any event with "searchTerm", returns filtered response according to "searchResponseTerm"
    * call read("searchAnEvent.feature")

    * def res = karate.match( "result == feature")
    * def found =  res.pass
    * match  found == true
    * print  "************** sent to Westpac - passed"
    * print payload
