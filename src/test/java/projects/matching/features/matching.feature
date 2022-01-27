Feature: matching

  @test-01-convert
  Scenario: convert string number to int number
    # method 1. multiply string with 1
    * def foo = '10'
    * string json = { bar: '#(1 * foo)' }
    * match json == '{"bar":10}'

     # method 1. Use parseInt() to convert string to number
    * string json = { bar: '#(parseInt(foo))' }
    * match json == '{"bar":10}'

  @test-02-file-paths
  Scenario: traverse through folders
    #same dir
    * def txt = read('test0.txt')
    * match txt == "same folder"

    # parent dir
    * def txt = read('../test1.txt')
    * match txt =="in parent folder"

    # another folder from parent dir
    * def txt = read('../data/test2.txt')
    * match txt =="in a separate folder"

    # another project
    * def txt = read('../../fileOps/resources/test.txt')
    * match txt =="Hello world"

