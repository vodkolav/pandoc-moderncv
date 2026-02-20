
# Compact Entries (`\cv...item` family)

Generally one-line content without fancy header.

If
1. DefList has a single definition
2. That single definition has no body of block elements (paragraph, code block, list, etc.)

Then it's mapped to one of the `\cv...item` family of macros.

## Simple items
Simple `Term : Definition` structures.

Compact Entry with a single field in Term. 

### cvitem
A Simple item with a single field in definition, maps to `\cvitem`.

```markdown
# Interests (cvitem)

hobby 1
: Description 1

hobby 2
: Description 2

hobby 3
: Description 3
```
maps to 

```latex
\section{Interests}
\cvitem{hobby 1}{Description 1}
\cvitem{hobby 2}{Description 2}
\cvitem{hobby 3}{Description 3}
```

### cvitemwithcomment

A Simple item with a Term, definition and a comment. The comment is in *italics* and is aligned to the right. 


A Simple item with 2 fields in the definition, maps to `\cvitemwithcomment`.

```markdown
# Languages (cvitemwithcomment)

**Klingon**
: native speaker | fluent in reading and writing

**English** 
: so-so | learned in kindergarten

Language 3
: Skill level | Comment

Language 4
: Skill level | Comment 

```
maps to 

```latex
\section{Languages (cvitemwithcomment)}
\cvitemwithcomment{Klingon}{native speaker}{fluent in reading and writing}
\cvitemwithcomment{English}{so-so}{learned in kindergarten}
\cvitemwithcomment{Language 3}{Skill level}{Comment}
\cvitemwithcomment{Language 4}{Skill level}{Comment} 
```

## Multi items 

Are a variant of simple items spread into several columns.

<pre>**Term 1** : Definition1          **Term 2** | Definition 2 </pre>


Multi items are defined as:  
A Compact Entry with a **composite** Term and a **composite** definition.  
In such case, the number of Term fields must match the number of definition fields. 
This number can be either 2 or 3 (for double or triple items), otherwise an error is raised. [^1]

### cvdoubleitem / cv**triple**item

If:
- Number of Term fields matches the number of definition fields

Then:
- DefList is mapped according to the number of fields to either `\cvdoubleitem` for 2 fields or `\cvtripleitem` for 3 fields,
- more than 3 fields raises an error. 
- each Term field being the item category. 
- each definition field being the item content. 

```markdown
# Computer skills (cvdoubleitem)
category Left | category Right
: content left | content right

category 2 | category 5 
: XXX, YYY, ZZZ | XXX, YYY, ZZZ

category Left | category Center | category Right (cvtripleitem)
: content left | content center | content right

category 3 | category 6
: XXX, YYY, ZZZ | XXX, YYY, ZZZ
```

maps to 

```latex
\cvdoubleitem{category Left}{content left}{category Right}{content right}
\cvdoubleitem{category 2}{XXX, YYY, ZZZ}{category 5}{XXX, YYY, ZZZ}
\cvtripleitem{category Left}{content left}{category Center}{content center}{category Right}{content right} 
\cvdoubleitem{category 3}{XXX, YYY, ZZZ}{category 6}{XXX, YYY, ZZZ}
```

Note that compact entries may have only one definition, which produces a single line of `category: content` singlet, doublet or triplet. To produce more lines, add more entries as shown in the example above. 

Each line will have its own categories, however. Currently, if you want to have multiple lines of doublets or triplets **under the same categories**, then you need to use complex entries with `\cvcolumns` macro. [^3]

It is possible to intermix double and triple items, as shown in the example above, but that's discouraged, as it will produce inconsistent, ugly formatting of the content. It's better to stick to one type of multi items within the same section, e.g. use only double items for skills, and only triple items for languages, etc.

## List items
A Compact Entry with a single Term field, multiple definitions, and no block content, maps to either `\cvlistitem` or `\cvlistdoubleitem` depending on the number of definition fields.
More than 2 definition fields raises an error.

### cvlistitem

If each definition has a single field, then the DefList maps to `\cvlistitem` as follows:

```markdown
list (omitted)
: Item 1 
: Item 2 
: Item 3
```

maps to 

```latex
\cvlistitem{Item 1}
\cvlistitem{Item 2}
\cvlistitem{Item 3}
```

### cvlistdoubleitem
If each definition has 2 fields, then the DefList maps to `\cvlistdoubleitem` as follows:

```markdown
<!-- single term (omitted), multiple definition, 2 fields, no block content -->
```markdown
double list (omitted)
: Item 1 | Item 4 
: Item 2 | Item 5 
: Item 3 | Item 6 
```

maps to 

```latex
\cvlistdoubleitem{Item 1}{Item 4}
\cvlistdoubleitem{Item 2}{Item 5}
\cvlistdoubleitem{Item 3}{Item 6}
``` 


# Detailed Entries 

Detailed entries are more complex items, which allow for more flexible formatting and structure of the content.

Defined as: 
The first definition has a body of block elements (paragraph, code block, list, etc.)


## cventry

If
1. A Detailed Entry has only one definition.

Then it's mapped to `\cventry` macro as follows:

- Term goes to first parameter of `\cventry`.
- Definition fields go to parameters 2-5 of the macro.
    - If Definition has less then 4 fields, the parameters of the missing definitions are left empty, e.g.: `...{Def2}{}{}...`
    - If Definition has more than 4 fields, an error is raised, as `\cventry` only supports 4 parameters for definition fields. [^2]
- Block elements go to parameter 6 of the macro.
- All inner formatting of Terms, definitions and Block elements of the DefinitionList is preserved. Their processing is done according to default pandoc logic.


Example: 

```markdown
Term
: Def1 | *Def2* | Def3 

    **regular blocks**
    more regular blocks
```

Maps to:
```latex
\cventry{Term}{Def1}{\textit{Def2}}{Def3}{}{
            \textbf{regular blocks} 
            more regular blocks
            }
``` 


## cvcolumns

A table-like structure for multiple items under the same categories.


If A Detailed Entry has multiple definitions, then DefList is mapped to `\cvcolumns` macro as follows:

- The Term is ignored, as columns don't have a common heading.
- each definition being a column heading, (with its fields being concatenated together if there are more than one, e.g. `Def1 | Def2` becomes `Def1 Def2`.)?
- each definition body being the content of `\\cvcolumn`, preserving all formatting.
- mixed cases need no special treatment. For example, if some definitions have body content, and some don't, then the ones without just produce an empty respective column. Leave it to the users to decide whether they want to have empty columns or not.


```markdown
Term (omitted)
: Category 1 

    reguar block content for category 1, \
    which can include lists, code blocks, etc.

: Category 2 

    - **Person 1**
    - Person 2
    - Person 3

: All the rest & some more

    That person \
    and those also \
    (all available upon request).
```

```latex
\begin{cvcolumns}
    \cvcolumn{Category 1}{reguar block content for category 1,\newline which can include lists,
code blocks, etc.}
    \cvcolumn{Category 2}{\begin{itemize}
\tightlist
\item
  \textbf{Person 1}
\item
  Person 2
\item
  Person 3
\end{itemize}}
    \cvcolumn{All the rest \& some more}{That person\newline and those also\newline (all available upon request).} 
\end{cvcolumns}
```

Note that the output of `\cvcolumns` is a tightly packed set of columns, which leaves little room for horizontal spacing. \
Therefore, it's recommended to:
- use this macro only for lists of short content, such as references, skills, etc., 
- use no more than 3-4 columns. 
- use mostly bullet points in the column content, as they are more compact and easier to read.
- It is user's responsibility to ensure that the content within each column is not too long or too wide, to avoid issues with horizontal spacing. Use the vertical structure of the markdown source to visually align the content within each column, e.g. by using line breaks (`\`) to control the horizontal spacing of the content within each column.

For longer content, it's better to use `\cventry`, which allows for more flexible formatting and spacing of the body content.


# Edge cases
Empty definitions or terms: these should not occur in practice, as such structure will not be recognized as a valid DefList by pandoc, and thus will not be processed by the filter. However, if it does occur, it can be treated as a special case and mapped to `\cvitem` with empty parameters.

# Pseudocode 
Below is the pseudocodefor item type determination logic. The DefinitionList function within `moderncv.lua` filter will implement this logic to determine the type of entry and map it to the corresponding LaTeX macro.

```pseudo
#definitions = 0 
    \\cvitem{term}{} --should not occur

#definitions > 0 
    definition[1] has block content  --?: or maybe at least one definition must have block content
        Term.#fields <> 1  
            error. complex items must have single field in term (no separators) 

        Term.#fields == 1
            #definitions == 1
                def1.#fields < 4
                    \\cventry{...}
                def1.#fields >= 4
                    error. cventry supports no more than 4 fields

            #definitions > 1
                --?: check if all definitions have block content? not necessary. if user wants empty column, let him have it. 
                --?: check if single field in all definitions? not necessary. all fields are concatenated together in the column heading, so if user wants to have multiple fields in some definitions, let him have it. 
                \\cvcolumns{...
                    \\cvcol{def1}{def1.block content}
                    \\cvcol{def2}{def2.block content}
                    \\cvcol{def3}{def3.block content}}
                            ... 

    definition[1] has NO block content  --?: or maybe all definitions must have no block content
        --cvitem family...

        #definitions = 1 
            --Simple items...
            Term.#fields = 1
                definition[1].#fields = 1 
                    \\cvitem{term}{def} 
                definition[1].#fields = 2 
                    \\cvitemwithcomment{term}{def.field1}{def.field2} 
                definition[1].#fields > 2
                    error. up to 2 fields supported. 
            
            Term.#fields > 3
                error. up to 3 items supported

            Term.#fields <> definition[1].#fields
                error. double/triple items must have same number of term fields as definitions fields.

                definition[1].#fields == 2 
                    \\cvdoubleitem{term1}{def.field1}{term2}{def.field2}

                definition[1].#fields == 3 
                    \\cvtripleitem{term1}{def.field1}{term2}{def.field2}{term3}{def.field3}


        #definitions > 1 
            Term.#fields <> 1
                error. list items must have single term field. 
                --? since it's omitted we may not care about term fields at all. 
                --? or maybe we can define proper amount of definition fields here? 

            Term.#fields == 1
                --List items...

                exists definition with #fields <> definition[1].#fields
                    error. all definitions must have same number of fields.

                Else: all definitions have same #fields 
                    definition[1].#fields == 1
                        \\cvlistitem{def1.field1}
                        \\cvlistitem{def2.field1}
                        ...

                    definition[1].#fields == 2
                        \\cvlistdoubleitem{def1.field1}{def1.field2}
                        \\cvlistdoubleitem{def2.field1}{def2.field2}
                        \\cvlistdoubleitem{def3.field1}{def3.field2}
                        ...

```

This should cover most common CV item types.


# Features to consider implementation later

## Babysitter for '|' character in content fields

a fix for cases where user typed '|' next to the other word. This prevents the content within definitions/terms to be recognized as fields.
Help user to easily fix it by replacing 'foo| bar' with 'foo | bar' (with spaces around |) in the markdown source. 

```regex
([^ +]?)\|([^ +])
```

replace pattern:
```regex
$1 | $2
```

## cvitem / cvdoubleitem / cvtripleitem with multiple definitions
[^3]: Interesting case to consider: if we allow for compact entries to have multiple definitions, then we can have multiple lines of single/double/triple items under the same categories, without the need to repeat the Term. This might be a more elegant solution, as it allows to group items under the same categories without repeating the categories themselves. However, it might also introduce some complexity in the parsing logic, as we need to determine when to treat multiple definitions as multiple lines of double/triple items, and when to treat them as separate entries. This is something to consider for future implementation.


## In case of complex items / cvcolumns :
Each Term field might have an optional width specification in square brackets, e.g. [0.5], to control the relative width of that column. This is a standard feature of moderncv, so we should support it as well 

```markdown
Category 1 | Category 2 | [0.5]All the rest \& some more 
: Person 1 | Person 2 | Person 3
: Person 42 | Person 0.37 | (more upon request)
: That person, and those also (all available upon request)
```
> Note: this is old spec syntax, but the principle is the same.

maps to

```latex
\begin{cvcolumns}
  \cvcolumn{Category 1}{\begin{itemize}\item Person 1\item Person 2\item Person 3\end{itemize}}
  \cvcolumn{Category 2}{Amongst others:\begin{itemize}\item Person 1, and\item Person 2\end{itemize}(more upon request)}
  \cvcolumn[0.5]{All the rest \& some more}{\textit{That} person, and \textbf{those} also (all available upon request).}
\end{cvcolumns}
```

## cvlistitem / cvlistdoubleitem

Consider using cvlistitem / cvlistdoubleitem for items within cventry instead of itemize lists. 

```latex
\cvlistitem{<item >}
\cvlistdoubleitem{<item 1>}{ item 2>}
```

## Skill matrix 
Consider using md tables for Skill matrix macros, smth like:

```markdown
# Skills matrix
| Skill       | Level  | Experience (years) |
|-------------|--------|--------------------|
| Python      | Expert | 10                 |
| C++         | Good   | 7                  |
```
maps to

```latex
\cvskill{Python}{Expert}{10}
\cvskill{C++}{Good}{7}
```

## Footnotes
[^1]: or maybe not error, but some other item type/family can be defined - to be considered later. 

[^2]: maybe instead of error, the extra parts are concatenated and put into the 5th parameter, e.g.: `...{Def4 Def5 Def6}...`
