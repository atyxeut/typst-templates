#import "@preview/mannot:0.4.0": *
#import "@preview/shadowed:0.3.0": *
#import "@preview/zebraw:0.6.3": *

#let regular_text_font = "LXGW WenKai GB"
#let bold_text_font = "LXGW ZhenKai GB"
#let math_font = "XCharter Math"
#let fallback_math_font = "New Computer Modern Math"
#let code_font = "Maple Mono NL NF"

#let char_width = 4.8mm
#let char_width_over_2 = char_width / 2;
#let char_width_over_4 = char_width / 4;
#let char_width_over_8 = char_width / 8;
#let char_width_over_12 = char_width / 12;
#let char_width_over_16 = char_width / 16;

// font size
#let char_height = char_width / 1.2

#let space_over_2 = h(char_width_over_2, weak: true)
#let space_over_4 = h(char_width_over_4, weak: true)
#let space_over_8 = h(char_width_over_8, weak: true)
#let space_over_12 = h(char_width_over_12, weak: true)
#let space_over_16 = h(char_width_over_16, weak: true)

#let style(body) = {
  set heading(numbering: none)
  show heading: set text(weight: "bold", font: bold_text_font)
  show heading.where(level: 1): set text(size: char_height * 1.7)
  show heading.where(level: 2): set text(size: char_height * 1.5)
  show heading.where(level: 3): set text(size: char_height * 1.3)
  show heading.where(level: 4): set text(size: char_height * 1.1)

  set text(
    cjk-latin-spacing: none,
    spacing: char_width_over_12,
    size: char_height,
    font: regular_text_font,
    weight: "regular",
    hyphenate: true,
  )

  set par(
    justify: true,
    linebreaks: "simple",
  )

  let (margin_x, margin_top, margin_bottom) = (10mm, 6mm, 14mm)
  let page_width = 30 * char_width + margin_x * 2
  set page(
    width: page_width,
    height: auto,
    margin: (x: margin_x, top: margin_top, bottom: margin_bottom),
    numbering: (
      cur_number,
      ..,
    ) => text(
      fill: luma(100),
      font: "Libertinus Serif",
      numbering("1", cur_number),
    ),
    footer-descent: margin_top,
  )

  show math.equation: set text(weight: "regular", font: (math_font, regular_text_font))
  show math.equation: it => {
    show regex("[,:;]"): char => char + space_over_4
    it
  }

  let code_font_size_factor = 0.75
  show raw: set text(
    font: code_font,
    size: char_height * code_font_size_factor,
    features: (calt: 0),
    spacing: char_width_over_2 * code_font_size_factor,
  )
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 4pt, y: 1pt),
    outset: (y: 3pt),
    radius: 1pt,
  )
  show: zebraw.with(inset: (top: 4pt, bottom: 4pt, left: 4pt, right: 4pt), indentation: 2, hanging-indent: true)

  body
}

// text block with an overridden spacing
#let stext(content) = text(spacing: char_width_over_4, content)

#let keyword(content, en: none) = text(
  weight: "medium",
  content + if en != none { "(" + stext(en) + ")" },
)

#let begin_chapter(chapter) = {
  [
    #let pos = chapter.position(regex("[A-Z]"))
    #let display = if pos != none {
      chapter.slice(0, pos) + " " + chapter.slice(pos, chapter.len())
    } else {
      chapter
    }
    #align(center)[= #display]
    #line(length: 100%, stroke: 0.75pt + black)
    #label(chapter)
  ]
}

#let begin_title(chapter, title) = { [== #title #label(chapter + "-" + title)] }

// must give a permanent `label_name`
#let content_block(text_color: white, background_color, label_name, title, en: auto, content) = {
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
            #text(fill: text_color, title + if en != auto { " " + "(" + stext(en) + ")" })
          ],
        )
        #content
      ]
    ]
    #label(label_name)
  ]
}

// axiom block
#let axiom_bg_color = rgb("#047857")
#let axiom(label_name, title, en: auto, content) = content_block(
  axiom_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// definition block
#let def_bg_color = rgb("#243daf")
#let def(label_name, title, en: auto, content) = content_block(
  def_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// proposition block
#let prop_counter = counter("prop")
#let prop_bg_color = rgb("#d97706")
#let prop(label_name, content) = {
  prop_counter.step()
  context content_block(
    prop_bg_color,
    label_name,
    "命题" + " " + prop_counter.display(),
    content,
  )
}

// theorem block
#let thm_bg_color = rgb("#be123c")
#let thm(label_name, title, en: auto, content) = content_block(
  thm_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// corollary block
#let cor_bg_color = rgb("#7e22ce")
#let cor(label_name, title, en: auto, content) = content_block(
  cor_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// algorithm block
#let algo_bg_color = rgb("#0e7490")
#let algo(label_name, title, en: auto, content) = content_block(
  algo_bg_color,
  label_name,
  title,
  en: en,
  content,
)

// proof block
#let proof_bg_color = black
#let proof(name: auto, content) = block(
  inset: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  [
    #text("证明" + if name != auto { name }, fill: proof_bg_color, weight: "bold", font: bold_text_font)
    #h(char_width_over_2, weak: true)
    #content
    #show math.equation: set text(font: fallback_math_font)

    #h(1fr) #text(fill: proof_bg_color)[$qed$]
  ],
)

// example block
#let eg_counter = counter("eg")
#let eg_bg_color = rgb("#334155")
#let eg(label_name, source: auto, content) = {
  eg_counter.step()
  context content_block(
    eg_bg_color,
    label_name,
    "例" + " " + eg_counter.display() + if source != auto { " " + "(" + source + ")" },
    content,
  )
}

#let get_title(label_name, type) = context {
  let target = label(label_name)
  if type == "prop" {
    "命题" + " " + str(prop_counter.at(query(target).first().location()).first())
  } else if type == "eg" {
    "例" + " " + str(eg_counter.at(query(target).first().location()).first())
  }
}

// a hyperlink to a label with description
#let tp(label_name, default_for: none, ..desc) = {
  set text(weight: "medium")
  let content = if default_for != none {
    underline(get_title(label_name, default_for))
  } else {
    text[#show math.equation.where(block: false): it => box(
        // directly adding an underline does not work
        it,
        stroke: (bottom: 0.2mm + black),
        outset: (bottom: 0.7mm),
      )
      #underline(desc.pos().first())]
  }
  link(label(label_name), content)
}

// numbered block equation
#let eqn(content) = {
  math.equation(block: true, numbering: "(1)", content)
}

#let eqrect(content) = markrect(outset: char_width_over_8, content);

#let rfact(x, n) = $#x^overline(#n)$
#let ffact(x, n) = $#x^underline(#n)$

#let stirling1(n, k) = $vec(#n, #k, delim: "[")$
#let stirling2(n, k) = $vec(#n, #k, delim: "{")$
#let eulerian(n, k) = $vec(#n, #k, delim: chevron)$
#let multinom(n, ..k) = $binom(#n, #k.pos().join("," + space_over_4))$

#let span(..vectors) = $upright("span")(#vectors.pos().join("," + space_over_4))$
#let rank(matrix) = $upright("rank")(matrix)$
