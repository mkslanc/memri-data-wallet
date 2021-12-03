# CVU: supported view definitions

The following view definitions are currently supported in CVU.

## Sessions

```css
[sessions = "name"] {
    [session] {
    }
}
```

## Session

```css
[session = "name"] {
    [view] {
    }
}
```

## View

### selector based on a list of the same types

```css
Person[] {
    title: "{firstName} {lastName}"
}
```

Use `*[]` to apply to a list of any datatypes
Use `mixed[]` to apply to a list of mixed datatypes

### selector based on the data item type and its properties

```css
Person {
    title: "{firstName} {lastName}"
}
```

Use `*` to apply to any data item

## Renderer

```css
[renderer = list] {
    press: openView
}
```

## Datasource

Selects where data is loaded from, to display in this view.

```css
[datasource = pod] {
    query: "Person"
}
```

## Color

The CVU language has built-in support for named colors that support dark and light mode. These colors can be defined using a color selector and can then be used in place of #333 style literal colors. In fact literal colors in views are highly discouraged. Users of views can override named colors in their settings, which they cannot do for literal colors.

```css
[color = "background"] {
    light: #330000
    dark: #ff0000
}

[color = "highlight"] {
    light: #000
    dark: #fff
}
```

## Style

Similarly styles can be combined into named sets that can then be applied to UI elements.

```css
[style = "my-label-text"] {
    border: background 1
    color: highlight
}

/* Example usage */
Text {
    style: my-label-text
}
```

## Language

Language selectors are used to specify text used in views in various natural languages, by replacing the text with variables. Here's an example:

```css
[language = "English"] {
    sharewith: "Share with..."
    addtolist: "Add to list..."
    duplicate: "Duplicate"
    showtimeline: "Show Timeline"
    timelineof: "Timeline of this"
    starred: "Starred"
    all: "All"
}
[language = "Dutch"] {
    sharewith: "Deel met..."
    addtolist: "Voeg toe aan lijst..."
    duplicate: "Dupliceer"
    showtimeline: "Toon Tijdslijn"
    timelineof: "Tijdslijn van deze"
    starred: "Favoriete"
    all: "Alle"
}

/* Example usage */
Text {
    text: "$sharewith"
}
```