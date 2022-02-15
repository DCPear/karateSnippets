@project:SFTPTemplete @story:TransferFile @Level:SFTP @endpoint:source @endpoint:target
Feature: This feature file tests a SFTP transfer between two endpoints. drop a file at source end and inspect the file from target end.

  Background:
#    * def user = "my username"
#    * def pwd = "my password"
    * def nowTime = Java.type("java.time.ZonedDateTime").now().minusHours(24)
    * def epoch = nowTime.toEpochSecond()

  Scenario:
    * print epoch
    * def params = { username :'#(user)', password: '#(pwd)'}
    * call read("classpath:utilities/splunk/splunkLogin.feature")  params



    * text searchTerm =
    """
    search index=openshift "<feature>" |  spath "message.RequestURL" | search "message.RequestURL"="<requestUrl>"
    """

    * replace searchTerm.feature = "MFP_INV_20220210_101717.txt"
    * replace searchTerm.requestUrl = base_url + "ACC_PPG_DC_D20220210_T101717"+ mode

    * print searchTerm
    * def searchReq = read("classpath:utilities/splunk/splunkSearchReq.json")

    * set searchReq.search = searchTerm
    * set searchReq.earliest_time = epoch

    * Java.type("java.lang.Thread").sleep(10000)
    * def search = call read("classpath:utilities/splunk/splunkSearch.feature")

    *  xml responseXml = search.response
    * print responseXml

    * def req = karate.xmlPath(search.response, "/results/result/field[@k='message.RequestURL']/value/text")
    * def application = karate.xmlPath(search.response, "/results/result/field[@k='message.ApplicationName']/value/text")
    * def callingApp = karate.xmlPath(search.response, "/results/result/field[@k='message.CallingApp']/value/text")
    * def logger = karate.xmlPath(search.response, "/results/result/field[@k='message.Logger']/value/text")
    * def timeStmp = karate.xmlPath(search.response, "/results/result/field[@k='message.TimeStamp']/value/text")
    * print " Request Url: " ,  req
    * print " ApplicationName: " ,  application
    * print "Calling app:" , callingApp
    * print "logger : " , logger
    * print "time stamp: ", timeStmp
