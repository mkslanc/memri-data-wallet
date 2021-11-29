# CVU: Actions

The following actions are supported in CVU.

Action | Arguments names and types | Description
---- | ---- | ----
back | | loads the previous view in the current session
addDataItem | template:DataItem | add an item based on a template
openView | view:View arguments:ViewArguments  | opens a new view based on a literal view definition
openViewByName | name:String viewArguments:ViewArguments | opens a view by name
toggleEditMode | | toggles edit mode in the renderer/editor in the current view
toggleFilterPanel | | shows and hides the filter panel
star | | toggles the starred property on the current or a selection of data items
showStarred | | filters the current view to show only the elements that are starred
showContextPane | | show the context pane
showNavigation | | show the main navigation
share | | (not implemented yet)
duplicate | | duplicate the current data item
schedule | | (not implemented yet)
addToList | name:String | (not implemented yet)
delete | | delete the current or selection of data items
setRenderer | name:Renderer | change the renderer that is displaying the content
select | | select one or more data items (not implemented)
selectAll | | select all data items (not implemented)
unselectAll | | unselect all data items (not implemented)
openLabelView, | | (not implemented)
showSessionSwitcher | | show the session switcher
forward | | load the next view in the current session
forwardToFront | | load the topmost view in the current session
backAsSession | | load the previous view in a new session (copies the history)
openSession | session:Session | loads a new session based on a literal session definition
openSessionByName | name:String | loads a new session by name
addSelectionToList | | (not implemented)
closePopup | | closes a subview that is opened in a popup
noop | | does not execute an action (can be used as a placeholder while working on a view)
