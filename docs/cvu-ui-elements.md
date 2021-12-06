# CVU UI elements

In CVU, UI elements are built by defining a nested collections of elements. Here follows the complete list of all UI elements definitions and their description.

Element Name | Description
----- | -----
VStack | Element that stacks its children vertically
HStack | Element that stacks its children horizontally
ZStack | Element that stacks its children on top of eachother
EditorSection | Element that renders as a section in the general editor
EditorRow | Element that renders as a row in a section in the general editor
EditorLabel | Element that renders a label in a row in the general editor
Button | Element that renders a button in the user interface. Buttons connect to 
FlowStack | Element that horizontally stacks its children and wraps to the next line at the end of the container.
Text | Element that renders text on the screen
Textfield | Element allows a user to change text
ItemCell | Element that renders a data item as if it was displayed in a specific renderer
SubView | Element that renders a view inside another view
Map | Element that displays content on a map
Picker | Element that allows a user to choose from a list of options
SecureField | Element that allows a user to change text while keeping the entry private
ActionButton | Element that 
MemriButton | Element that displays a cononical representation of a data item
Image | Element that displays an image
Circle | Element that renders a circle
HorizontalLine | Element that renders a horizontal line
Rectangle | Element that renders a rectangle
RoundedRectangle | Element that renders a rounded rectangle
Spacer | Element that maximizes the space between elements in a stack
Divider | Element that renders a divider line
Empty | Element that does not render anything

## Element properties

The following element properties are supported in CVU.

Property | Possible values | Description
---- | ---- | ----
resizable | String | set do "stretch", "fit", "fill" to determine how the element is resized (esp. Image)
show | Boolean | whether to show the element or not. Use an expression to toggle visibility (e.g. {{labels.count}}).
alignment | String | set to "center", "top", "left", "bottom", "right" to set the alignment of children of the stack element.
align | String | set to "center", "top", "left", "bottom", "right" to set the alignment of the element relative to their siblings in a stack.
textalign | String | set to "left", "center", "right" to determine how text is aligned.
spacing | Number | sets the space between elements in a stack.
title | String | sets the title of an element.
text | String | set the text of a Text element
image | String, File, URL(not supported yet) | sets the image location of an Image element
nopadding | Boolean | sets whether to display padding in a section in the general editor 
press | Action | sets the action to be executed when the user presses the button
bold | Boolean | sets whether the text is rendered bold
italic | Boolean | sets whether the text is rendered italic
underline | Boolean | sets whether the text is rendered underline
strikethrough | Boolean | sets whether the text is rendered strikethrough
list | Array | sets a list to iterate over (used by FlowStack, ForEach (not supported yet))
viewName | String | sets the name of the view to display in the SubView
view | View | sets a literal definition of a view to load in the SubView
viewArguments | Dict | sets a dict of named arguments to pass to an ItemCell or SubView
location, | Location | sets a location to render on the Map element
address | Address | sets an address to render on the Map element
systemname | String | sets the system name of the image to display in the Image element
cornerradius | Number | sets the rounding of the corners of the element
hint | String | sets the hint to display in a TextField to inform a user what to type
value | String | sets the value of a form element
datasource | String | sets the datasource of a view
defaultValue | String | sets the default value of a form element
empty | String | sets the empty message displayed in a text element
style | Array, String | sets the style classes to apply to the element
color | Color | sets the text color of an element
font | Number String | sets the size of the font and the boldness: "thin", "ultrathin", "regular", "semibold", "medium", "bold"
padding | Array, Number | Set the distance between the content of the element and its edge. Either one number for all edges, or one for each.
background | Color | sets the color of the background of the element
rowbackground | color | sets the color of the background of the row in the list renderer
border | Color Number | sets the color of the border and its size
margin | Array, Number | Set the distance between the edge of the element and its neighbors and parent. Either one number for all edges, or one for each.
shadow | Array | 
offset | Number Number | Sets the x and y offset
blur | Number | Sets the level of blur between 0 and 1 
opacity | Number | Sets the opacity of the element between 0 and 1
zindex | Number | Sets the zindex controling which element is rendered on top of the other
minWidth | Number | Sets the minimal width of the element
maxWidth | Number | Sets the maximal width of the element
minHeight | Number | Sets the minimal height of the element
maxHeight | Number | Sets the maximal height of the element

N.B. Each of these properties can be calculated using the CVU expression language.
