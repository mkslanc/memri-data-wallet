# CVU: An introduction

Memri comes with the CVU (pronounced as: c view) language that enables you to control how you view and use your information. CVU (c-view) stands for Cascading Views. It’s a language that is easy to understand and allows you to control how your information is rendered in your memri frontend by changing items in the Pod. With the CVU language you can describe how you want to view data such as notes, emails, messages and photos. Memri comes with a default set of CVU definitions that you can use on the most common data types (e.g. note, person, address, photo). Users can also define their own views. 


## Why another language?
The main reason to have another language is that your CVU definitions can be stored as data in the Pod. This means we don't have to recompile the app to update the UI, which in turn means we don't have update the software to update the UI. In combination with our dynamic schema, this is great for making dynamic plugins, that not only change the data in the database, but also can define how that data is displayed on your screen.  We want CVU to be accessible and easy to use for non-programmers. Therefore, we created an easy-to-write script that could quickly load at runtime into Memri. We made the views cascade in order to allow the user to easily modify their views.

## Define your view
Let's dive in and create a view to render the notes in the list view.

In order to define how notes are rendered, let's create a new cvu file called "note.cvu" and add a selector for a list of notes. For illustration purpose we also add the selector for a single note:

```less
/* A view for a single note */
Note {

}
```
```less
/* A view for multiples notes */
Note[] {

}
```

Like in CSS, selectors select the content to which the instructions are applied. In the case of CSS these instructions are styling applied to HTML elements. In the case of CVU these are rendering instructions applied to data items. See this wiki article for a complete list of supported definitions.

```less
Note[] {
    /* Sets the list as the default renderer when notes are viewed */
    defaultRenderer: list

    [renderer = list] {
    
    }
}
```

## Rendering instructions
We can define how to render our data, in this case our notes, in various renderers. Let's start with a definition for the list renderer.

```less
[renderer = list] {
    slideRightActions: schedule

    VStack {
        alignment: left
        padding: 12 20 0 20
        
        Text {
            text: "{.title}"
            font: 18 semibold
            color: #333
            padding: 0 0 3 0
        }
        Text {
            text: "{.content}"
            removeWhiteSpace: true
            maxChar: 100
            color: #555
            font: 14 regular
        }
        Text {
            text: "{.dateModified}"
            font: 11 regular
            color: #888
            padding: 8 0 12 0
        }
        Divider
    }
}
```
