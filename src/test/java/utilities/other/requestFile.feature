@project:ERP @story:UploadFileToAzureStorage @Level:upload @endpoint:AzureBlobStorage
Feature: Upload supplier payment file to Azure Blob Storage in order to trigger SupplierPaymentRequestSubscriber

  Background:
    * def testData = read(mfp_sp_data)

    * def dateStamp = javaLib.DateUtils.todaysDate('yyyyMMdd')
    * def timeStamp =  javaLib.DateUtils.todaysDate('HHmmss')
    * def requestFile = MFPText + dateStamp +'_'+ timeStamp + '.txt'
    * def transformedFile = MFPBacho +'D' + dateStamp+'_'+ 'T'+ timeStamp

    * def filesUtils = Java.type('utilities.common.FilesUtils')

    * def userDir = karate.properties['user.dir']
    * def inputPath = userDir +"/" + inputs_path

    # function - check if the transformed file is created
    * def waitUntil =
      """
        function(f) {
          var count = 0
          while (true) {
           var myFile = new java.io.File(f);
            karate.log('poll response: checking ', myFile);
            if (myFile.exists()|| count==5){
               karate.log('condition satisfied, exiting');
               return myFile.exists();
            }
             karate.log('sleeping');
             ++count;
             karate.log(count);
            java.lang.Thread.sleep(30000);
            }
            }
    """

      # function - call java pgm conditionally to convert the transformed file back to CSV for verification
    * def convertToCSV =
      """
       function(f,FU,input,output,headings,mappings){
       if (f){
         var convertPgm = FU;
         var cp = new  convertPgm
         return FU.convertBachoToCsv(input,output,headings,mappings)
        }
      }
      """

  Scenario Outline: Upload supplier payment file to Azure Blob Storage

      # 1. Upload Supplier payment file to Azure storage
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

    # 2. Create a CSV (CSV1) of the uploaded File
    *  filesUtils.replaceFirstLine(requestBody, req_csv_root, firstLine);

    # 3. Check if the transformed file is created in Archive
    * def externalFile = external_path + transformedFile
    * print "external file", externalFile
    * def found = call waitUntil externalFile
    * print "== status", found

    #4. If transformed file is found convert it back to CSV (CSV2)
    * def deleted = filesUtils.deleteAFile(output_csv_root)
    * print "deleted: ", deleted
    * def converted = convertToCSV (found,filesUtils,externalFile,output_csv_root,headings, mappings)
    * print "== converted", converted

    #4. If the CSV2 is created call verification to compare CSV1 and CSV2
    * def size = filesUtils.getSize(output_csv_root)
    * print "== size", size
    * def params = {input: '#(req_csv)', output:'#(output_csv)', time:'#(timeStamp)' }
    * def result = (converted == size) ? karate.call('verifyData.feature', params): null

    Examples:
      | testCase             |
      | testData.testCase_01 |
      | testData.testCase_02 |
      | testData.testCase_03 |

