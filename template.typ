#import "@preview/mannot:0.4.0": *
#import "@preview/shadowed:0.3.0": *
#import "@preview/zebraw:0.6.3": *

#let char_width = 4mm
#let char_height = char_width / 1.2
#let text_font = "Maple Mono NL NF"
#let math_font = "XCharter Math"

#let style(body) = {
  set heading(numbering: none)
  show heading.where(level: 1): it => text(it, size: char_height * 1.5)
  show heading.where(level: 2): it => text(it, size: char_height * 1.3)
  show heading.where(level: 3): it => text(it, size: char_height * 1.1)

  set text(
    cjk-latin-spacing: auto,
    spacing: char_width / 2,
    size: char_height,
    font: text_font,
    weight: "light",
    hyphenate: true,
  )

  set par(
    justify: true,
    linebreaks: "simple",
  )

  let char_count_per_line = 32
  let (margin_x, margin_y) = (10mm, 8mm)
  let page_width = char_count_per_line * char_width + margin_x * 2
  set page(width: page_width, height: auto, margin: (x: margin_x, y: margin_y))

  let space = h(1mm, weak: true)
  show math.equation: set text(font: math_font)
  show math.equation.where(block: false): it => {
    let it = {
      show regex("[,:;]"): char => char + space
      it
    }
    space + it + space
  }

  // inline code block setting
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 4pt, y: 1pt),
    outset: (y: 3pt),
    radius: 0.2em,
  )
  // code block setting
  show: zebraw.with(inset: (top: 4pt, bottom: 4pt, left: 4pt, right: 4pt), indentation: 2, hanging-indent: true)
  show raw: set text(font: text_font, size: char_height * 0.75, features: (calt: 0))

  body
}

#let begin_chapter(chapter) = {
  [
    #align(center)[
      #show heading: it => text(chapter, size: char_height * 1.7, weight: "bold")
      #heading(chapter)
    ]
    #line(length: 100%, stroke: 0.75pt + black)
    #label(chapter)
  ]
}

#let begin_title(chapter, title) = { [= #title #label(chapter + "-" + title)] }

#let define_functions(chapter, title) = {
  let label_string(chapter, title: auto, name: auto) = (
    chapter + if title != auto { "-" + title } + if name != auto { "-" + name }
  )

  let take_until(string, delim: "(") = {
    let pos = string.position(delim)
    if pos == none {
      string
    } else {
      string.slice(0, pos)
    }
  }

  let content_block(text_color: white, background_color, title, content, target) = {
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
      #label(target)
    ]
  }

  // definition block
  let def_bg_color = rgb("#243daf")
  let def(name, content) = content_block(
    def_bg_color,
    name,
    content,
    label_string(chapter, title: title, name: take_until(name)),
  )

  // proposition block
  let prop_counter = counter(chapter + "-" + title + "prop")
  let prop_bg_color = rgb("#d97706")
  let prop(content) = [
    #prop_counter.step()
    #context {
      let name = "命题" + prop_counter.display()
      content_block(
        prop_bg_color,
        name,
        content,
        label_string(chapter, title: title, name: name),
      )
    }
  ]

  // theorem block
  let thm_bg_color = rgb("#be123c")
  let thm(name, content) = content_block(
    thm_bg_color,
    name,
    content,
    label_string(chapter, title: title, name: take_until(name)),
  )

  // corollary block
  let cor_bg_color = rgb("#7e22ce")
  let cor(name, content) = content_block(
    cor_bg_color,
    name,
    content,
    label_string(chapter, title: title, name: take_until(name)),
  )

  // example block
  let eg_counter = counter(chapter + "-" + title + "eg")
  let eg_bg_color = rgb("#334155")
  let eg(source: "", content) = [
    #eg_counter.step()
    #context {
      let name = "例" + eg_counter.display() + if source != "" { "(" + source + ")" }
      content_block(
        eg_bg_color,
        name,
        content,
        label_string(chapter, title: title, name: take_until(name)),
      )
    }
  ]

  // proof block
  let proof_bg_color = black
  let proof(name: auto, content) = block(
    inset: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
    [
      #text(fill: proof_bg_color, weight: "bold", "证明" + if name != auto { "(" + name + ")" }) #h(
        char_width / 2,
        weak: true,
      )
      #content
      #show math.equation: set text(font: "New Computer Modern")

      #h(1fr) #text(fill: proof_bg_color)[$qed$]
    ],
  )

  // a hyperlink to <chapter-title-name>
  let tp(chapter, title, name, desc: auto, omit_chapter: false, omit_title: false) = {
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
      label(label_string(chapter, title: title, name: name)),
      text(weight: "medium")[#show math.equation.where(block: false): it => box(
          it,
          stroke: (bottom: 0.168mm + black),
          outset: (bottom: 0.516mm),
          inset: (left: 1mm, right: 1mm),
        )
        #underline(desc)],
    )
  }
  // a hyperlink with "chapter-" already filled
  let ctp(title, name, desc: auto) = tp(
    chapter,
    title,
    name,
    desc: desc,
    omit_chapter: true,
  )
  // a hyperlink with "chapter-title-" already filled
  let cttp(name, desc: auto) = tp(
    chapter,
    title,
    name,
    desc: desc,
    omit_chapter: true,
    omit_title: true,
  )

  (def: def, prop: prop, thm: thm, cor: cor, eg: eg, proof: proof, tp: tp, ctp: ctp, cttp: cttp)
}

#let keyword(content) = text(content, weight: "medium")

// alias of numbered math.equation
#let eqn(content) = {
  math.equation(block: true, numbering: "(1)", content)
}
#let eqnrect(content) = $markrect(padding: #0.2em, content)$;

#let rfact(x, n) = $#x^overline(#n)$
#let ffact(x, n) = $#x^underline(#n)$

#let stirling1(n, k) = $vec(#n, #k, delim: "[")$
#let stirling2(n, k) = $vec(#n, #k, delim: "{")$
#let eulerian(n, k) = $vec(#n, #k, delim: chevron)$
#let multinom(n, ..k) = $binom(#n, #k.pos().join("," + h(1mm, weak: true)))$
