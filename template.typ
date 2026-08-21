#import "@preview/mannot:0.4.0": *
#import "@preview/shadowed:0.3.0": *
#import "@preview/zebraw:0.6.3": *

#let text_font = "Maple Mono NL NF"
#let char_width = 4mm
#let char_height = char_width / 1.2

#let math_font = "XCharter Math"

#let char_width_2 = char_width / 2;
#let char_width_4 = char_width / 4;
#let char_width_8 = char_width / 8;
#let char_width_12 = char_width / 12;

#let space_2 = h(char_width_2, weak: true)
#let space_4 = h(char_width_4, weak: true)
#let space_8 = h(char_width_8, weak: true)
#let space_12 = h(char_width_12, weak: true)

#let style(body) = {
  set heading(numbering: none)
  show heading.where(level: 1): it => text(it, size: char_height * 1.5)
  show heading.where(level: 2): it => text(it, size: char_height * 1.3)
  show heading.where(level: 3): it => text(it, size: char_height * 1.1)

  set text(
    cjk-latin-spacing: auto,
    spacing: char_width_2,
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

  show math.equation: set text(font: math_font, weight: "regular")
  show math.equation.where(block: false): it => {
    show regex("[,:;]"): char => char + space_4
    it
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

// must give a permanent `label_name`
#let content_block(text_color: white, background_color, label_name, title, title_en: auto, content) = {
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
            #space_12
            #text(weight: "regular", fill: text_color, if title_en != auto {
              "(" + title_en + ")"
            })
          ],
        )
        #content
      ]
    ]
    #label(label_name)
  ]
}

// definition block
#let def_bg_color = rgb("#243daf")
#let def(label_name, title, title_en: auto, content) = content_block(
  def_bg_color,
  label_name,
  title,
  title_en: title_en,
  content,
)

// proposition block
#let prop_counter = counter("prop")
#let prop_bg_color = rgb("#d97706")
#let prop(label_name, content) = [
  #prop_counter.step()
  #context {
    let name = "命题" + prop_counter.display()
    content_block(
      prop_bg_color,
      name,
      label_name,
      content,
    )
  }
]

// theorem block
#let thm_bg_color = rgb("#be123c")
#let thm(label_name, title, title_en: auto, content) = content_block(
  thm_bg_color,
  label_name,
  title,
  title_en: title_en,
  content,
)

// corollary block
#let cor_bg_color = rgb("#7e22ce")
#let cor(label_name, title, title_en: auto, content) = content_block(
  cor_bg_color,
  label_name,
  title,
  title_en: title_en,
  content,
)

// algorithm block
#let algo_bg_color = rgb("#0e7490")
#let algo(label_name, title, title_en: auto, content) = content_block(
  algo_bg_color,
  label_name,
  title,
  title_en: title_en,
  content,
)

// proof block
#let proof_bg_color = black
#let proof(name: auto, content) = block(
  inset: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  [
    #text(fill: proof_bg_color, weight: "bold", "证明" + if name != auto { name }) #h(
      char_width_2,
      weak: true,
    )
    #content
    #show math.equation: set text(font: "New Computer Modern")

    #h(1fr) #text(fill: proof_bg_color)[$qed$]
  ],
)

// example block
#let eg_bg_color = rgb("#334155")
#let eg(label_name, source: auto, content) = [
  #context content_block(
    eg_bg_color,
    label_name,
    "例" + if source != auto { "(" + source + ")" },
    content,
  )
]

#let tp(label_name, desc) = link(
  label(label_name),
  text(weight: "medium")[#show math.equation.where(block: false): it => box(
      it,
      stroke: (bottom: 0.168mm + black),
      outset: (bottom: 0.516mm),
      inset: (left: char_width_8, right: char_width_8),
    )
    #underline(desc)],
)

#let keyword(content, content_en: auto) = {
  text(content, weight: "medium")
  space_12
  text(weight: "regular", if content_en != auto {
    "(" + content_en + ")"
  })
}

// most frequently used equation
#let eq(content, rmargin: true) = {
  space_8 + content + if rmargin { space_8 }
}

// when the equation is followed by a punctuation
#let eqs(content) = eq(content, rmargin: false)

// numbered block equation
#let eqn(content) = {
  math.equation(block: true, numbering: "(1)", content)
}

#let eqrect(content) = markrect(outset: char_width_8, content);

#let rfact(x, n) = $#x^overline(#n)$
#let ffact(x, n) = $#x^underline(#n)$

#let stirling1(n, k) = $vec(#n, #k, delim: "[")$
#let stirling2(n, k) = $vec(#n, #k, delim: "{")$
#let eulerian(n, k) = $vec(#n, #k, delim: chevron)$
#let multinom(n, ..k) = $binom(#n, #k.pos().join("," + space_4))$
