# CVU Expression Language

The following expressions are currently supported in CVU.

## Arithmetic Operators
```python
(5 + 10 * 4 - 3 / 10) / 10 # result: 4.470000000000001
```

## And and Or conditional statements
```python
true and false # result: false
true or false # result: true
```

## And and Or to select values
```python
.age > 18 and "Ask an adult question?" # result: only when the age is over 18 the text is displayed
.title or "Untitled Note" # result: a string with the title or "Untitled Note" when title is not set
```

## Conditions
```python
true ? 'yes' : 'no' # result: 'yes
true ? false and true ? -1 : false or true ? 'yes' : 'no' : -1 # result: 'yes
```

## Comparison
```python
true = false # result: false
true != false # result: true
5 > 10 # result: false
10 >= 5 # result: true
5 < 10 # result: true
10 <= 5 # result: false
```

## Variable Lookup and function execution
```python
.bar and bar.foo(10) and bar[foo = 10] or shouldNeverGetHere"
```

## Plus and minus variable modifier
```python
-5 + -(5+10) - +'5' # result: -25
```
    
## Negation
```python
!true # result: false
```
    
## Strings
```python
'asdadsasd\\'asdasd' # result: "asdadsasd'asdasd"
```
    
## Type conversion
```python
5 + '10.34' + true # result: 16.34
0 ? -1 : 1 ? '' ? -1 : 'yes' : -1 # result: -1
```

## String mode
```python
"Hello {fetchName()}!"
"Hello {.firstName} {.lastName}"
"{fetchName()} Hello"
```

## Edge traversal
```python
.label[] # Returns a list of items that are connect with edge type label
._label[] # Returns a list of edges with edge type label
.label # Returns the first item with edge type label
.label[.firstName = "James"] # Returns a list of item for which firstName is "James"
._label[.sequence > 3] # Returns a list of edges for which sequence is larger than 3
._~label # Returns the first reverse edge for which edge type is label
._~label[] # Returns a list of reverse edges for which edge type is label
.~label # Returns an item connected via a reverse edges for which edge type is label
.~label[] # Returns a list of items connected via a reverse edges for which edge type is label
```
## Variables and Properties
The available variables change based on the context. For instance certain renderers make additional variables available. The following variables are always available.
```python
me # A reference to the Person item that represents the user
context # A reference to the context instance
context.showSessionSwitcher # A boolean to toggle the session switcher
context.showNavigation # A boolean to toggle the navigation

sessions # A reference to all the sessions
sessions[i:Number] # a reference to a session in the list of all sessions

currentSession # A reference to the current session
session # A reference to the current session
session.name # The name of the session
session.editMode # Whether the session is in edit mode
session.showContextPane
session.showFilterPanel
session.screenshot

currentView # A reference to the current view
view # A reference to the current view
view.name
view.datasource
view.datasource.query
view.datasource.sortProperty
view.datasource.sortAscending
view.contextPane
view.userState
view.userState.<key>
view.viewArguments
view.viewArguments.<key>
view.resultSet
view.activeRenderer
view.backTitle
view.searchHint
view.actionButton
view.titleActionButton
view.editActionButton
view.sortFields
view.filterButtons
view.contextButtons
view.renderConfig
view.emptyResultText
view.title
view.subtitle
view.filterText
view.searchMatchText

singletonItem # A reference to the current single item, when in a single item view
singletonItem.<field> 
```

## Functions
```python
setting(path:String) # Returns the value of a setting. e.g. setting('device/upload/cellular')
item() # Returns the context item i.e. synonymous with {{.}}
item(typeName:String, uid:Number) # Returns a specific item of a type with uid. e.g. item(Person, 10920823990)
debug(message1:Any[, message2:Any[, ...]]) # Prints one or more variables in the debug console e.g. debug(item())
min(value1:Number, value2:Number) # Returns the lowest value. e.g. min(5, 0) -> 0
max(value1:Number, value2:Number) # Returns the largest value. e.g. max(5, 0) -> 5
floor(value:Number) # Returns the closes smaller integer. e.g. floor(5.3) -> 5
ceil(value:Number) # Returns the closes larger integer. e.g. floor(5.3) -> 6
```

## Methods for types
```python
item.describeChangelog() # Short description of how this item was changed since it was created
item.computedTitle() # A title for this item
item.edge(edgeType:String) # An alternative way to get an edge, via a string
item.edges(edgeType:String) # An alternative way to get a list of edges, via a string

string.uppercased # turn the string to all caps
string.lowercased # turn the string to all lower case
string.camelCaseToWords # change a camel cased string to words. e.g. helloBeautifulWorld -> Hello Beautiful World
string.plural # not implemented (currently only adds an s to the end)
string.firstUppercased # first letter is upper cased
string.plainString # strip all HTML
string.count # the number of characters in the string

date.format() # format the date based on the user defined setting for a long date format
date.format("time") # format the date based on the user defined setting for time
date.format(format:String) # format the date based on a formatting string. e.g. date.format("YYYY HH:mm")
date.timeSince1970 # retrieve the number of milliseconds of the date since 1/1/1970
date.timeSinceNow # retrieve the number of milliseconds of the date from now

edge.source # fetch the source item of the edge
edge.target # fetch the target item of the edge
edge.item # fetch the target item of the edge
edge.label # the label of the edge
edge.type # the type of the edge (e.g. "brother")
edge.sequence # the sequence number of an edge that is in an ordered list of edges

edges.count # the number of edges in the list
edges.first # the first edge in the list
edges.last # the last edge in the list
edges.items # a list of items that the list of edges point to
```