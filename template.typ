#import "@preview/mannot:0.4.0": *
#import "@preview/shadowed:0.3.0": *
#import "@preview/zebraw:0.6.3": *

#let normal_text_size = 4mm;

#let style(body) = {
  set page(width: 176mm, height: auto, margin: (x: 12mm, y: 10mm))

  set par(
    justify: true,
    linebreaks: "simple",
  )

  set text(
    hyphenate: true,
    // font: ("Libertinus Serif", "LXGW WenKai GB"),
    font: "LXGW WenKai GB",
    size: normal_text_size,
    weight: "light",
  )

  set heading(numbering: none)

  set terms(hanging-indent: 0em)

  show math.equation: set text(font: "XCharter Math")
  show math.equation.where(block: false): it => h(1mm, weak: true) + it + h(1mm, weak: true)

  // inline code block setting
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 4pt, y: 1pt),
    outset: (y: 3pt),
    radius: 0.2em,
  )

  // code block setting
  show: zebraw.with(inset: (top: 4pt, bottom: 4pt, left: 4pt, right: 4pt), indentation: 2, hanging-indent: true)
  show raw: set text(font: "Maple Mono NL NF", size: 3.5mm, features: (calt: 0))

  body
}

#let content_block(text_color: white, background_color, title, content, label_string) = {
  let cur_inset = 14pt
  [
    #v(1em)
    #shadow(radius: 2pt, dx: 1pt, dy: 1pt, blur: 2pt, fill: background_color.lighten(80%))[
      #block(
        fill: background_color.lighten(95%),
        stroke: 0.5pt + background_color.lighten(50%),
        radius: 2pt,
        width: 100%,
        inset: cur_inset,
        above: 2em,
      )[
        #place(
          top + left,
          dx: 10pt - cur_inset,
          dy: -10pt - cur_inset,
          rect(fill: background_color.lighten(20%), radius: 1pt, inset: 2.5pt, outset: 2pt)[
            #text(weight: "regular", fill: text_color, title)
          ],
        )
        #content
      ]
    ]
    #label(label_string)
  ]
}

#let take_until(string, delim: "(") = {
  let pos = string.position(delim)
  if pos == none {
    string
  } else {
    string.slice(0, pos)
  }
}

#let label_string(chapter, title: auto, name: auto) = (
  chapter + if title != auto { "-" + title } + if name != auto { "-" + name }
)

#let definition_background_color = rgb("#243daf")
#let definition(chapter, title, name, content) = content_block(
  definition_background_color,
  name,
  content,
  label_string(chapter, title: title, name: take_until(name)),
)

#let proposition_background_color = rgb("#d97706")
#let proposition(chapter, title, counter, content) = [
  #counter.step()
  #context {
    let name = "命题" + counter.display()
    content_block(
      proposition_background_color,
      name,
      content,
      label_string(chapter, title: title, name: name),
    )
  }
]

#let theorem_background_color = rgb("#be123c")
#let theorem(chapter, title, name, content) = content_block(
  theorem_background_color,
  name,
  content,
  label_string(chapter, title: title, name: take_until(name)),
)

#let corollary_background_color = rgb("#7e22ce")
#let corollary(chapter, title, name, content) = content_block(
  corollary_background_color,
  name,
  content,
  label_string(chapter, title: title, name: take_until(name)),
)

#let example_background_color = rgb("#334155")
#let example(chapter, title, source: "", content) = {
  let name = "例" + if source != "" { " " + "(" + source + ")" }
  content_block(
    example_background_color,
    name,
    content,
    label_string(chapter, title: title, name: take_until(name)),
  )
}

#let proof_background_color = black
#let proof(content) = block(
  inset: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  [
    #text(fill: proof_background_color, weight: "bold")[证明] #h(4pt)
    #content
    #show math.equation: set text(font: "New Computer Modern")

    #h(1fr) #text(fill: proof_background_color)[$qed$]
  ],
)

// use standard label if there is no title
#let mark(chapter, title, name: auto) = label(
  label_string(chapter, title: title, name: name),
)

#let portal(chapter, title, name, desc: auto, omit_chapter: false, omit_title: false) = {
  let desc = if desc != auto {
    desc
  } else {
    if omit_chapter and omit_title {
      label_string(name)
    } else if omit_chapter {
      label_string(title, name: name)
    }
  }
  link(
    mark(chapter, title, name: name),
    text(weight: "bold")[#show math.equation.where(block: false): it => box(
        it,
        stroke: (bottom: 0.2mm + black),
        outset: (bottom: 0.7mm),
        inset: (left: 1mm, right: 1mm),
      )
      #underline(desc)],
  )
}

#let define_functions(chapter, title) = {
  let prop_counter = counter(chapter + "-" + title)
  let prop(content) = proposition(chapter, title, prop_counter, content)

  let def(name, content) = definition(chapter, title, name, content)
  let thm(name, content) = theorem(chapter, title, name, content)
  let cor(name, content) = corollary(chapter, title, name, content)
  let eg(source: "", content) = example(chapter, title, source: source, content)

  // chapter portal: target label is prefixed with "chapter-"
  let cptl(title, name, desc: auto) = portal(
    chapter,
    title,
    name,
    desc: desc,
    omit_chapter: true,
  )

  // local portal: target label is prefixed with "chapter-title-"
  let ptl(name, desc: auto) = portal(
    chapter,
    title,
    name,
    desc: desc,
    omit_chapter: true,
    omit_title: true,
  )

  (prop: prop, def: def, thm: thm, cor: cor, eg: eg, cptl: cptl, ptl: ptl)
}

#let header(title) = {
  align(center)[
    #show heading: it => text(title, size: 22pt, weight: "regular")
    #heading(title)
  ]
  line(length: 100%, stroke: 0.75pt + black)
}

#let rfact(x, n) = $#x^overline(#n)$
#let ffact(x, n) = $#x^underline(#n)$

// alias of numbered math.equation
#let eqn(content) = {
  math.equation(block: true, numbering: "(1)", content)
}
#let eqnrect(content) = $markrect(padding: #0.2em, content)$;
