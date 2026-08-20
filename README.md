# Kernel Tutorials

Personal collection of long-form Linux kernel tutorials, written in Markdown
and rendered to PDF, ODT, and HTML via [Pandoc](https://pandoc.org/). Each
`*.md` file is a self-contained tutorial on some kernel subsystem, pinned to
a specific upstream tag/rc (stated in its own intro section).

## Layout

- `*.md` — tutorial sources. Each one builds independently.
- `Makefile` — build rules (see below).
- `header.tex` — LaTeX preamble tweaks for the PDF build (code-block
  shading, line-breaking).
- `break-code.lua` — Pandoc Lua filter: inserts break points into long
  inline code spans and soft-wraps long fenced-code-block lines.
- `reference.odt` — style template for the ODT build (fonts, margins, link
  color, code-block shading), so ODT output matches the PDF's look.
- `style.css` — stylesheet for the HTML build, for the same reason.

## Building

```sh
make        # renders every *.md into a same-named *.pdf (pandoc + xelatex)
make pdf    # same as above, explicitly
make odt    # renders every *.md into a same-named *.odt
make html   # renders every *.md into a same-named, self-contained *.html
make all    # pdf + odt + html
make clean  # removes all generated PDF/ODT/HTML output
```

## Dependencies

- **Pandoc** 2.19 or newer (tested with 3.7) — the `--embed-resources` flag
  used by the HTML build requires at least 2.19.
- **A LaTeX distribution with XeLaTeX** — used as Pandoc's PDF engine, for
  proper system-font and Unicode support.
- **Fonts**: DejaVu Serif and Source Code Pro (referenced by name in the
  `Makefile`'s `-V mainfont=`/`monofont=`, in `reference.odt`, and in
  `style.css`), plus DejaVu Sans (referenced only in the `Makefile`'s PDF
  build via `-V sansfont=` — the ODT and HTML builds don't use it).
- **GNU Make**.

### Installing on Fedora

```sh
# Pandoc
sudo dnf install pandoc-cli

# Fonts
sudo dnf install dejavu-serif-fonts dejavu-sans-fonts dejavu-sans-mono-fonts \
                  adobe-source-code-pro-fonts

# Build tooling
sudo dnf install make

# LaTeX (XeLaTeX + the packages header.tex and Pandoc's template need)
sudo dnf install texlive-scheme-full
```

`texlive-scheme-full` is the simplest reliable option but is a large
install (several GB) — it exists so nothing ever fails later with a missing
`.sty` file. If disk space matters more than convenience, a leaner
alternative that covers everything the current `Makefile`/`header.tex` use
is:

```sh
sudo dnf install texlive-xetex texlive-collection-latex \
                  texlive-fontspec texlive-geometry texlive-xcolor \
                  texlive-hyperref texlive-microtype texlive-fancyvrb \
                  texlive-framed texlive-hyphenat
```

With the leaner install, a future tutorial that needs a LaTeX package not
listed above (via a `header.tex` change) will fail at build time with a
"File `<name>.sty` not found" error from XeLaTeX — install the matching
`texlive-<name>` package (Fedora's `texlive-*` package names match the
upstream CTAN package names) and rebuild.
