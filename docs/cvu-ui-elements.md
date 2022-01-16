# CVU UI elements

In CVU, UI elements are built by defining a nested collections of elements. Here follows the complete list of all UI elements definitions and their description.

Element Name | Description
----- | -----
VStack | Element that stacks its children vertically
HStack | Element that stacks its children horizontally
ZStack | Element that stacks its children on top of each other
EditorSection | Element that renders as a section in the general editor
EditorRow | Element that renders as a row in a section in the general editor
EditorLabel | Element that renders a label in a row in the general editor
Button | Element that renders a button in the user interface.
FlowStack | Element that horizontally stacks its children and wraps to the next line at the end of the container.
Text | Element that renders text on the screen
Textfield | Element allows a user to change text
SubView | Element that renders a view inside another view
Map | Element that displays content on a map
Picker | Element that allows a user to choose from a list of options
ActionButton | Element that renders button connected to some predefined action 
MemriButton | Element that displays a canonical representation of a data item
Image | Element that displays an image
Circle | Element that renders a circle
Rectangle | Element that renders a rectangle
RoundedRectangle | Element that renders a rounded rectangle
Spacer | Element that maximizes the space between elements in a stack
Divider | Element that renders a divider line
Empty | Element that does not render anything
CVUDropZone | Element that renders drop zone component for web version
Observer | Element that renders component listening for some property  (in case we need continuously updated UI, if property changed)
Toggle | Element that displays toggle element
HTMLView | Element that displays WebView for mobile platform and iframe for web
Grid | Element that displays table with elements

## Element properties

The following element properties are supported in CVU.

Property | Possible values | Description | CVU Elements
---- | ---- | ---- | ----
show | Boolean | whether to show the element or not. Use an expression to toggle visibility (e.g. {{labels.count}}). | All
alignment | String | set to "center", "top", "left", "bottom", "right" to set the alignment of children of the stack element. | VStack, HStack, ZStack, EditorRow
textalign | String | set to "left", "center", "right" to determine how text is aligned. | Text, SmartText
spacing | Number | sets the space between elements in a stack. | VStack, HStack, ZStack, SubView, Grid, FlowStack
title | String | sets the title of an element. | SubView
text | String | set the text of a Text element | Text, SmartText
image | String, File | sets the image location of an Image element | Image
nopadding | Boolean | sets whether to display padding in a section in the general editor | EditorRow
onPress | Action | sets the action to be executed when the user presses the button | Button, ActionButton
bold | Boolean | sets whether the text is rendered bold | Text, SmartText
italic | Boolean | sets whether the text is rendered italic | Text, SmartText
underline | Boolean | sets whether the text is rendered underline | Text, SmartText
strikethrough | Boolean | sets whether the text is rendered strikethrough | Text, SmartText
list | Array | sets a list to iterate over (used by FlowStack, ForEach (not supported yet)) | FlowStack
viewName | String | sets the name of the view to display in the SubView | SubView
view | View | sets a literal definition of a view to load in the SubView | SubView
viewArguments | Dict | sets a dict of named arguments to pass to an ItemCell or SubView | SubView
location, | Location | sets a location to render on the Map element | Map
address | Address | sets an address to render on the Map element | Map
systemname | String | sets the system name of the image to display in the Image element | Image
cornerradius | Number | sets the rounding of the corners of the element | All
cornerradiusOnly | Array | sets the rounding of the corners of the element (separately for each corner | All
hint | String | sets the hint to display in a TextField to inform a user what to type | TextField
value | String, Boolean | sets the value of a form element | TextField, Toggle
datasource | String | sets the datasource of a view
empty | String | sets the empty message displayed in a text element
styleName | String | applies the chosen style to the element (_primaryButton_ only for now) | Button
color | Color | sets the text color of an element | Text, SmartText, Button, Circle, Image(vector only), TextField
font | Number, String | sets the size of the font and the boldness: "thin", "ultrathin", "regular", "semibold", "medium", "bold" | Text, Button, SmartText
padding | Array, Number | Set the distance between the content of the element and its edge. Either one number for all edges, or one for each. | All
background | Color | sets the color of the background of the element | All
border | Color | sets the color of the border | All
shadow | Array | sets shadow for the element  | All
offset | Number Number | Sets the x and y offset | All
opacity | Number | Sets the opacity of the element between 0 and 1 | All
minWidth | Number | Sets the minimal width of the element | All
maxWidth | Number | Sets the maximal width of the element | All
minHeight | Number | Sets the minimal height of the element | All
maxHeight | Number | Sets the maximal height of the element | All
width | Number | Sets the width of the element | All
height | Number | Sets the height of the element | All
isLink | Boolean | changes button to special element with web link behaviour  | Button
src | String | sets url from which WebView(iframe) should load content | HTMLView
content | String | sets direct content for WebView(iframe) | HTMLView
isVector | Boolean | sets type of image | Image
property | String | sets property to observe | Observer
item | Item | sets item, which property we need to observe | Observer

N.B. Each of these properties can be calculated using the CVU expression language.
