@project:ERP @story:UploadFileToAzureStorage @Level:upload @endpoint:AzureBlobStorage
Feature: Upload supplier payment file to Azure Blob Storage in order to trigger SupplierPaymentRequestSubscriber

  Background:
    * def testData = read(mfp_sp_data)

    * def dateStamp = javaLib.DateUtils.todaysDate('yyyyMMdd')
    * def timeStamp =  javaLib.DateUtils.todaysDate('HHmmss')
    * def requestFile = MFPText + dateStamp +'_'+ timeStamp + '.txt'
    * def transformedFile = MFPBacho +'D' + dateStamp+'_'+ 'T'+ timeStamp

    * def filesUtils = Java.type('utilities.common.FilesUtils')
    * def codeUtils = Java.type("utilities.common.CodeUtils")

    * def userDir = karate.properties['user.dir']
    * def inputPath = userDir +"/" + inputs_path

    * def nowTime = Java.type("java.time.ZonedDateTime").now().minusHours(24)
    * def epoch = nowTime.toEpochSecond()

    * def username = codeUtils.base64Decode(user)
    * def password = codeUtils.base64Decode(pwd)


 # function - call java pgm conditionally to convert the transformed file back to CSV for verification
    * def convertToCSV =
      """
       function(f,FU,output,headings,mappings,res_root,payload){
       if (f){
         FU.deleteAFile(res_root)
         FU.writeResponseToFile2(payload, res_root)
         return FU.convertBachoToCsv(res_root,output,headings,mappings)
        }
      }
      """

  Scenario Outline: Upload supplier payment file to Azure Blob Storage

      # 1. Upload Supplier payment file to Azure storage - expected return response 201- created
    * print inputPath
    * def requestBody = read(inputPath  + <testCase>.req_txt)
    * def params =
    """
     {
        requestFile :'#(requestFile)', requestBody : '#(requestBody)',
        base:'#(base_url)', blob:'#(blob)',
        sv:'#(sv_value)', ss:'#(ss_value)', srt:'#(srt_value)',
        sp:'#(sp_value)', se:'#(se_value )', st:'#(st_value)',
        spr:'#(spr_value)', sig:'#(sig_value)'
        }
        """

    * def finalResult = call read('classpath:utilities/azureStorage/uploadToBlob.feature') params
    * match finalResult.responseStatus == 201

    # 2. Create a CSV (CSV1) of the uploaded File to be used to verification later
    *  Java.type("java.lang.Thread").sleep(60000)
    *  filesUtils.replaceFirstLine(requestBody, req_csv_root, firstLine);

    # 3. login Splunk to search transformation process activities logging
    * def params = { username :'#(username)', password: '#(password)'}
    * call read("classpath:utilities/splunk/splunkLogin.feature")  params

    # Search criteria - correlation id (request file name) and APIM request URL .
    * text searchTerm =
    """
    search index=openshift "<feature>" |  spath "message.RequestURL" | search "message.RequestURL"="<requestUrl>"
    """

    # 4. Set search event - transformed file sending to Westpac.  Retrieve payload.
    * replace searchTerm.feature = requestFile
    * replace searchTerm.requestUrl = apim_url +"to_WESTPAC_DEV_MFP_E63/"+ transformedFile + mode
    * print searchTerm

    * def searchReq = read("classpath:utilities/splunk/splunkSearchReq.json")
    * set searchReq.search = searchTerm
    * set searchReq.earliest_time = epoch
    * Java.type("java.lang.Thread").sleep(10000)

    # Call search
    * def search = call read("classpath:utilities/splunk/splunkSearch.feature")

    # Get correlation id from response to confirm the log is found
    *  xml responseXml = search.response
    *  print responseXml
    * def to_westpac =  karate.xmlPath(search.response, "/results/result/field[@k='message.CorrelationID']/value/text")
    * def res = karate.match( "to_westpac == requestFile")

    # If found - retrieve payload
    * def found =  res.pass
    * match  found == true
    * print  "************** sent to Westpac - passed"
    * def payload = karate.xmlPath(search.response, "/results/result/field[@k='message.Payload']/value/text")
    * print payload

    # convert payload to CSV2 to compare with CSV1 created in step2
    * def converted = convertToCSV(found,filesUtils,output_csv_root,headings, mappings, res_root, payload)
    * print "converted", converted

   #5. If the CSV2 is created call verification to compare CSV1 and CSV2
    * def size = filesUtils.getSize(output_csv_root)
    * print "== size", size
    * def params = {input: '#(req_csv)', output:'#(output_csv)', time:'#(timeStamp)' }
    * def result = (converted == size) ? karate.call('verifyData.feature', params): null
    * print "************** Data transformation verification passed"

  # 6. Set search event - transformed file sending to CCMM
    * replace searchTerm.feature = requestFile
    * replace searchTerm.requestUrl = apim_url +"to_Splunk_DEV_MFP_E63/"+ transformedFile + mode
    * print searchTerm

    * def searchReq = read("classpath:utilities/splunk/splunkSearchReq.json")
    * set searchReq.search = searchTerm
    * set searchReq.earliest_time = epoch
    # Call search
    * def search = call read("classpath:utilities/splunk/splunkSearch.feature")

    # Get correlation id from response to confirm the log is found
    *  xml responseXml = search.response
    *  print responseXml
    * def to_ccmm =  karate.xmlPath(search.response, "/results/result/field[@k='message.CorrelationID']/value/text")
    * def res = karate.match( " to_ccmm == requestFile")
    * match  res.pass == true
    * print  "************** sent to CCMM - passed"

    #7 Set search event - transformed file sending to ARCHIVE
    * replace searchTerm.feature = requestFile
    * replace searchTerm.requestUrl = apim_url +"to_ACCFILES_DEV_MFP_E63/"+ transformedFile + mode
    * print searchTerm

    * def searchReq = read("classpath:utilities/splunk/splunkSearchReq.json")
    * set searchReq.search = searchTerm
    * set searchReq.earliest_time = epoch
    # Call search
    * def search = call read("classpath:utilities/splunk/splunkSearch.feature")

    # Get correlation id from response to confirm the log is found
    *  xml responseXml = search.response
    *  print responseXml
    * def to_ccmm =  karate.xmlPath(search.response, "/results/result/field[@k='message.CorrelationID']/value/text")
    * def res = karate.match( " to_ccmm == requestFile")
    * match  res.pass == true
    * print  "************** sent to ARCHIVE - passed"

     #7 Set search event - transformed file sending to back to MFP
    * replace searchTerm.feature = requestFile
    * replace searchTerm.requestUrl = apim_url +"to_MFP_E63/"+ transformedFile + mode
    * print searchTerm

    * def searchReq = read("classpath:utilities/splunk/splunkSearchReq.json")
    * set searchReq.search = searchTerm
    * set searchReq.earliest_time = epoch
    # Call search
    * def search = call read("classpath:utilities/splunk/splunkSearch.feature")

    # Get correlation id from response to confirm the log is found
    *  xml responseXml = search.response
    *  print responseXml
    * def to_ccmm =  karate.xmlPath(search.response, "/results/result/field[@k='message.CorrelationID']/value/text")
    * def res = karate.match( " to_ccmm == requestFile")
    * match  res.pass == true
    * print  "************** sent to Back to MFP - passed"

    Examples:
      | testCase             |
#      | testData.testCase_01 |
      | testData.testCase_02 |
#      | testData.testCase_03 |

