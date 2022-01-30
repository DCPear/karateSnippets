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

  @test-03-advanced-match
  Scenario: advanced match in js
    * def foo = {a:1, b:'foo'}
    * def res = karate.match("foo contains{a: '#number'}")
    * match res == {pass: true, message:null}
    * def res = karate.match("foo == {a: '#number'}")
    * match res == {pass: false, message: '#notnull'}

    * def foo = [1,2,3]
    * def res = karate.match("each foo == '#number'")
    * match res == {pass: true, message:null}

  @test-03-self-validation
  Scenario: self validation
    * def date = { month: 3 }
    * match date == { month: '#? _ > 0 && _ < 13' }

    * def date = { month: 3 }
    * def min = 1
    * def max = 12
    * match date == { month: '#? _ >= min && _ <= max' }

    * def date = { month: 3 }
    * def isValidMonth = function(m) { return m >= 0 && m <= 12 }
    * match date == { month: '#? isValidMonth(_)' }

    # given this invalid input (string instead of number)
    * def date = { month: '3' }
    # this will pass
    * match date == { month: '#? _ > 0' }
    # but this 'combined form' will fail, which is what we want
    # * match date == { month: '#number? _ > 0' }

    Given def temperature = { celsius: 100, fahrenheit: 212 }
    Then match temperature == { celsius: '#number', fahrenheit: '#? _ == $.celsius * 1.8 + 32' }
    # when validation logic is an 'equality' check, an embedded expression works better
    Then match temperature contains { fahrenheit: '#($.celsius * 1.8 + 32)' }

  @test-04-match-text-or-binary
  Scenario: match text or binary
    # when the response is plain-text
    * def response = 'Health Check OK'
    Then match response == 'Health Check OK'
    And match response != 'Error'
    * assert  response == 'Health Check OK'
    * match response contains 'OK'
    * match response !contains 'blah'

  @test-05-match-xml
  Scenario: match xml
    * def xml = <root><hello>world</hello><foo>bar</foo></root>
    * match xml == <root><hello>world</hello><foo>#ignore</foo></root>
    * def xml = <root><hello foo="bar">world</hello></root>
    * match xml == <root><hello foo="#ignore">world</hello></root>

  @test-05-match-json
  Scenario: match json
    * def foo = { bar: 1, baz: 'hello', ban: 'world' }

    * match foo contains { bar: 1 }
    * match foo contains { baz: 'hello' }
    * match foo contains { bar:1, baz: 'hello' }
    # this will fail
    # * match foo == { bar:1, baz: 'hello' }

    * def foo = { bar: 1, baz: 'hello', ban: 'world' }
    * match foo !contains { bar: 2 }
    * match foo !contains { huh: '#notnull' }

    * def foo = { a: 1 }
    * match foo == { a: '#number', b: '#notpresent' }

    # if b can be present (optional) but should always be null
    * match foo == { a: '#number', b: '##null' }

    * def foo = [1, 2, 3]
    * match foo !contains 4
    * match foo !contains [5, 6]

  @test-06-match-json-array
  Scenario: match json array

    Given def cat =
  """
  {
    name: 'Billie',
    kittens: [
      { id: 23, name: 'Bob' },
      { id: 42, name: 'Wild' }
    ]
  }
  """

    # normal 'equality' match. note the wildcard '*' in the JsonPath (returns an array)
    Then match cat.kittens[*].id == [23, 42]

# when inspecting a json array, 'contains' just checks if the expected items exist
# and the size and order of the actual array does not matter
    Then match cat.kittens[*].id contains 23
    Then match cat.kittens[*].id contains [42]
    Then match cat.kittens[*].id contains [23, 42]
    Then match cat.kittens[*].id contains [42, 23]

# the .. operator is great because it matches nodes at any depth in the JSON "tree"
    Then match cat..name == ['Billie', 'Bob', 'Wild']

# and yes, you can assert against nested objects within JSON arrays !
    Then match cat.kittens contains [{ id: 42, name: 'Wild' }, { id: 23, name: 'Bob' }]

# ... and even ignore fields at the same time !
    Then match cat.kittens contains { id: 42, name: '#string' }

  @test-07-match-contains-only
  Scenario: match contains only
    * def data = { foo: [1, 2, 3] }
    * match data.foo contains 1
    * match data.foo contains [2]
    * match data.foo contains [3, 2]
    * match data.foo contains only [3, 2, 1]
    * match data.foo contains only [2, 3, 1]
    # this will fail
    # * match data.foo contains only [2, 3]

  @test-08-match-contains-any
  Scenario: match contains any
    * def data = { foo: [1, 2, 3] }
    * match data.foo contains any [9, 2, 8]
    * def data = { a: 1, b: 'x' }
    * match data contains any { b: 'x', c: true }

  @test-09-match-contains-deep
  Scenario: recurse nested json
    * def original = { a: 1, b: 2, c: 3, d: { a: 1, b: 2 } }
    * def expected = { a: 1, c: 3, d: { b: 2 } }
    * match original contains deep expected

  Scenario: recurse nested array
    * def original = { a: 1, arr: [ { b: 2, c: 3 }, { b: 3, c: 4 } ] }
    * def expected = { a: 1, arr: [ { b: 2 }, { c: 4 } ] }
    * match original contains deep expected

  @test-10-match-each
  Scenario: Validate every element in a JSON array
    * def data = { foo: [{ bar: 1, baz: 'a' }, { bar: 2, baz: 'b' }, { bar: 3, baz: 'c' }]}

    * match each data.foo == { bar: '#number', baz: '#string' }

# and you can use 'contains' the way you'd expect
    * match each data.foo contains { bar: '#number' }
    * match each data.foo contains { bar: '#? _ != 4' }

# some more examples of validation macros
    * match each data.foo contains { baz: "#? _ != 'z'" }
    * def isAbc = function(x) { return x == 'a' || x == 'b' || x == 'c' }
    * match each data.foo contains { baz: '#? isAbc(_)' }

# this is also possible, see the subtle difference from the above
    * def isXabc = function(x) { return x.baz == 'a' || x.baz == 'b' || x.baz == 'c' }
    * match each data.foo == '#? isXabc(_)'
    Given def json =
  """
  {
    "hotels": [
      { "roomInformation": [{ "roomPrice": 618.4 }], "totalPrice": 618.4  },
      { "roomInformation": [{ "roomPrice": 679.79}], "totalPrice": 679.79 }
    ]
  }
  """
    Then match each json.hotels contains { totalPrice: '#? _ == _$.roomInformation[0].roomPrice' }
# when validation logic is an 'equality' check, an embedded expression works better
    Then match each json.hotels contains { totalPrice: '#(_$.roomInformation[0].roomPrice)' }

  @test-10-schema-validation
  Scenario: schema-validation
    * def foo = ['bar', 'baz']

# should be an array
    * match foo == '#[]'

# should be an array of size 2
    * match foo == '#[2]'

# should be an array of strings with size 2
    * match foo == '#[2] #string'

# each array element should have a 'length' property with value 3
    * match foo == '#[]? _.length == 3'

# should be an array of strings each of length 3
    * match foo == '#[] #string? _.length == 3'

# should be null or an array of strings
    * match foo == '##[] #string'
    * def oddSchema = { price: '#string', status: '#? _ < 3', ck: '##number', name: '#regex[0-9X]' }
    * def isValidTime = read('time-validator.js')
    When method get
    Then match response ==
  """
  {
    id: '#regex[0-9]+',
    count: '#number',
    odd: '#(oddSchema)',
    data: {
      countryId: '#number',
      countryName: '#string',
      leagueName: '##string',
      status: '#number? _ >= 0',
      sportName: '#string',
      time: '#? isValidTime(_)'
    },
    odds: '#[] oddSchema'
  }
  """
    # optional (can be null) and if present should be an array of size greater than zero
    * match $.odds == '##[_ > 0]'

# should be an array of size equal to $.count
    * match $.odds == '#[$.count]'

# use a predicate function to validate each array element
    * def isValidOdd = function(o){ return o.name.length == 1 }
    * match $.odds == '#[]? isValidOdd(_)'

    * def cat =
  """
  {
    name: 'Billie',
    kittens: [
      { id: 23, name: 'Bob' },
      { id: 42, name: 'Wild' }
    ]
  }
  """
    * def expected = [{ id: 42, name: 'Wild' }, { id: 23, name: 'Bob' }]
    * match cat == { name: 'Billie', kittens: '#(^^expected)' }

    * def cat =
  """
  {
    name: 'Billie',
    kittens: [
      { id: 23, name: 'Bob' },
      { id: 42, name: 'Wild' }
    ]
  }
  """
    * def kitnums = get cat.kittens[*].id
    * match kitnums == [23, 42]
    * def kitnames = get cat $.kittens[*].
    * def kitnums = $cat.kittens[*].id
    * match kitnums == [23, 42]
    * def kitnames = $cat.kittens[*].name
    * match kitnames == ['Bob', 'Wild']name
    * match kitnames == ['Bob', 'Wild']
    * match cat.kittens[*].id == [23, 42]
    * match cat.kittens[*].name == ['Bob', 'Wild']

# if you prefer using 'pure' JsonPath, you can do this
    * match cat $.kittens[*].id == [23, 42]
    * match cat $.kittens[*].name == ['Bob', 'Wild']
    * def actual = 23

# so instead of this
    * def kitnums = get cat.kittens[*].id
    * match actual == kitnums[0]

# you can do this in one line
    * match actual == get[0] cat.kittens[*].id

  @test-11-json-path-filters
  Scenario: json-path-filters
    * def cat =
  """
  {
    name: 'Billie',
    kittens: [
      { id: 23, name: 'Bob' },
      { id: 42, name: 'Wild' }
    ]
  }
  """
# find single kitten where id == 23
    * def bob = get[0] cat.kittens[?(@.id==23)]
    * match bob.name == 'Bob'

# using the karate object if the expression is dynamic
    * def temp = karate.jsonPath(cat, "$.kittens[?(@.name=='" + bob.name + "')]")
    * match temp[0] == bob

# or alternatively
    * def temp = karate.jsonPath(cat, "$.kittens[?(@.name=='" + bob.name + "')]")[0]
    * match temp == bob


  @test-12-json-transforms
  Scenario: karate map operation
    * def fun = function(x){ return x * x }
    * def list = [1, 2, 3]
    * def res = karate.map(list, fun)
    * match res == [1, 4, 9]

  Scenario: convert an array into a different shape
    * def before = [{ foo: 1 }, { foo: 2 }, { foo: 3 }]
    * def fun = function(x){ return { bar: x.foo } }
    * def after = karate.map(before, fun)
    * match after == [{ bar: 1 }, { bar: 2 }, { bar: 3 }]

  Scenario: convert array of primitives into array of objects
    * def list = [ 'Bob', 'Wild', 'Nyan' ]
    * def data = karate.mapWithKey(list, 'name')
    * match data == [{ name: 'Bob' }, { name: 'Wild' }, { name: 'Nyan' }]

  Scenario: karate filter operation
    * def fun = function(x){ return x % 2 == 0 }
    * def list = [1, 2, 3, 4]
    * def res = karate.filter(list, fun)
    * match res == [2, 4]

  Scenario: forEach works even on object key-values, not just arrays
    * def keys = []
    * def vals = []
    * def idxs = []
    * def fun =
    """
    function(x, y, i) {
      karate.appendTo(keys, x);
      karate.appendTo(vals, y);
      karate.appendTo(idxs, i);
    }
    """
    * def map = { a: 2, b: 4, c: 6 }
    * karate.forEach(map, fun)
    * match keys == ['a', 'b', 'c']
    * match vals == [2, 4, 6]
    * match idxs == [0, 1, 2]

  Scenario: filterKeys
    * def schema = { a: '#string', b: '#number', c: '#boolean' }
    * def response = { a: 'x', c: true }
    # very useful for validating a response against a schema "super-set"
    * match response == karate.filterKeys(schema, response)
    * match karate.filterKeys(response, 'b', 'c') == { c: true }
    * match karate.filterKeys(response, ['a', 'b']) == { a: 'x' }

  Scenario: merge
    * def foo = { a: 1 }
    * def bar = karate.merge(foo, { b: 2 })
    * match bar == { a: 1, b: 2 }

  Scenario: append
    * def foo = [{ a: 1 }]
    * def bar = karate.append(foo, { b: 2 })
    * match bar == [{ a: 1 }, { b: 2 }]

  Scenario: sort
    * def foo = [{a: { b: 3 }}, {a: { b: 1 }}, {a: { b: 2 }}]
    * def fun = function(x){ return x.a.b }
    * def bar = karate.sort(foo, fun)
    * match bar == [{a: { b: 1 }}, {a: { b: 2 }}, {a: { b: 3 }}]
    * match bar.reverse() == [{a: { b: 3 }}, {a: { b: 2 }}, {a: { b: 1 }}]

  @test-13-loops
  Scenario:loops
    * def fun = function(i){ return i * 2 }
    * def foo = karate.repeat(5, fun)
    * match foo == [0, 2, 4, 6, 8]

    * def foo = []
    * def fun = function(i){ karate.appendTo(foo, i) }
    * karate.repeat(5, fun)
    * match foo == [0, 1, 2, 3, 4]

# generate test data easily
    * def fun = function(i){ return { name: 'User ' + (i + 1) } }
    * def foo = karate.repeat(3, fun)
    * match foo == [{ name: 'User 1' }, { name: 'User 2' }, { name: 'User 3' }]

# generate a range of numbers as a json array
    * def foo = karate.range(4, 9)
    * match foo == [4, 5, 6, 7, 8, 9]

  @test-14-xpath
  Scenario: xpath
    * def myXml =
  """
  <records>
    <record index="1">a</record>
    <record index="2">b</record>
    <record index="3" foo="bar">c</record>
  </records>
  """

    * match foo count(/records//record) == 3
    * match foo //record[@index=2] == 'b'
    * match foo //record[@foo='bar'] == 'c'

    * def teachers =
  """
  <teachers>
    <teacher department="science">
      <subject>math</subject>
      <subject>physics</subject>
    </teacher>
    <teacher department="arts">
      <subject>political education</subject>
      <subject>english</subject>
    </teacher>
  </teachers>
  """
    * match teachers //teacher[@department='science']/subject == ['math', 'physics']

    * def xml = <query><name><foo>bar</foo></name></query>
    * def elementName = 'name'
    * def name = karate.xmlPath(xml, '/query/' + elementName + '/foo')
    * match name == 'bar'
    * def queryName = karate.xmlPath(xml, '/query/' + elementName)
    * match queryName == <name><foo>bar</foo></name>

  @test-15-special-variable
  Scenario: special variables
  * def response = { name: 'Billie' }
    # the three lines below are equivalent
    Then match response $ == { name: 'Billie' }
    Then match response == { name: 'Billie' }
    Then match $ == { name: 'Billie' }

    # the three lines below are equivalent
    Then match response.name == 'Billie'
    Then match response $.name == 'Billie'
    Then match $.name == 'Billie'

    # the four lines below are equivalent
    * def response = <cat><name>Billie</name></cat>
    Then match response / == <cat><name>Billie</name></cat>
    Then match response/ == <cat><name>Billie</name></cat>
    Then match response == <cat><name>Billie</name></cat>
    Then match / == <cat><name>Billie</name></cat>

# the three lines below are equivalent
    Then match response /cat/name == 'Billie'
    Then match response/cat/name == 'Billie'
    Then match /cat/name == 'Billie'

