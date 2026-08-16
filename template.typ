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

#let take_until(string, delim: "(") = {
  let pos = string.position(delim)
  if pos == none {
    string
  } else {
    string.slice(0, pos)
  }
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

#let label_string(label_prefix, title, suffix: "") = label_prefix + "-" + title + if suffix != "" { "-" + suffix }

#let definition_background_color = rgb("#243daf")
#let definition_impl(label_prefix, title, content) = content_block(
  definition_background_color,
  title,
  content,
  label_string(label_prefix, take_until(title), suffix: "定义"),
)

#let proposition_background_color = rgb("#d97706")
#let proposition_impl(label_prefix, counter, content) = [
  #counter.step()
  #context {
    let title = "命题" + counter.display()
    content_block(
      proposition_background_color,
      title,
      content,
      label_string(label_prefix, title),
    )
  }
]

#let theorem_background_color = rgb("#be123c")
#let theorem_impl(label_prefix, title, content) = content_block(
  theorem_background_color,
  title,
  content,
  label_string(label_prefix, take_until(title)),
)

#let corollary_background_color = rgb("#7e22ce")
#let corollary_impl(label_prefix, title, content) = content_block(
  corollary_background_color,
  title,
  content,
  label_string(label_prefix, take_until(title)),
)

#let example_background_color = rgb("#0e7490")
#let example_impl(label_prefix, source: "", content) = {
  let title = "例" + if source != "" { " " + "(" + source + ")" }
  content_block(
    example_background_color,
    title,
    content,
    label_string(label_prefix, take_until(title)),
  )
}

#let proof_background_color = black
#let proof(title: "证明", content) = block(
  inset: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  [
    #text(fill: proof_background_color, weight: "bold")[#title] #h(4pt)
    #content
    #show math.equation: set text(font: "New Computer Modern")

    #h(1fr) #text(fill: proof_background_color)[$qed$]
  ],
)

#let define_functions(label_prefix) = {
  let proposition_counter = counter(label_prefix)

  let label_to(title, suffix: "") = label(label_string(label_prefix, title, suffix: suffix))
  let definition(title, content) = definition_impl(label_prefix, title, content)
  let proposition(content) = proposition_impl(label_prefix, proposition_counter, content)
  let theorem(title, content) = theorem_impl(label_prefix, title, content)
  let corollary(title, content) = corollary_impl(label_prefix, title, content)
  let example(source: "", content) = example_impl(label_prefix, source, content)

  (
    label_to: label_to,
    definition: definition,
    proposition: proposition,
    theorem: theorem,
    corollary: corollary,
    example: example,
  )
}

#let link_to(label, description) = link(label)[#text("[" + description + "]", weight: "bold")]

#let header(title) = {
  align(center)[
    #show heading: it => text(title, size: 22pt, weight: "regular")
    #heading(title)
  ]
  line(length: 100%, stroke: 0.75pt + black)
}

// alias of numbered math.equation
#let eqn(content) = {
  math.equation(block: true, numbering: "(1)", content)
}
#let eqnrect(content) = $markrect(padding: #0.2em, content)$;
