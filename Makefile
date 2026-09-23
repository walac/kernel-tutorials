SRC  := jumplabels.md
PDF  := $(patsubst %.md,%.pdf,$(SRC))
ODT  := $(patsubst %.md,%.odt,$(SRC))
HTML := $(patsubst %.md,%.html,$(SRC))
TXT  := $(patsubst %.md,%.txt,$(SRC))
JEKYLL := $(patsubst %.md,%.jkl.md,$(SRC))

FILTERS	 := $(wildcard *.lua)
TEX_DEPS := $(wildcard *.tex)

BLOG_DIR  ?= $(HOME)/work/walac.github.io
POST_DATE ?= $(shell date +%Y-%m-%d)

AUTHOR := Wander Lairson Costa
LANG   := en-US
TITLE   = $$(sed -n '1s/^\# *//p' $<)

%.pdf: %.md $(FILTERS) $(TEX_DEPS)
	sed '1d' $< | pandoc -o $@ \
		--top-level-division=part \
		--pdf-engine=xelatex \
		--toc --toc-depth=3 \
		--highlight-style=tango \
		--lua-filter=secnum.lua \
		--lua-filter=break-code.lua \
		-H header.tex \
		-V documentclass=report \
		-V geometry:margin=1.5cm \
		-V mainfont="DejaVu Serif" \
		-V sansfont="DejaVu Sans" \
		-V monofont="Source Code Pro" \
		-V fontsize=10pt \
		-V linestretch=1.15 \
		-V colorlinks=true \
		-V linkcolor=NavyBlue \
		-V urlcolor=NavyBlue \
		-V citecolor=NavyBlue \
		--metadata title="$(TITLE)" \
		--metadata author="$(AUTHOR)" \
		--metadata lang="$(LANG)"

%.odt: %.md $(FILTERS) reference.odt
	sed '1d' $< | pandoc -o $@ \
		--toc --toc-depth=3 \
		--highlight-style=tango \
		--lua-filter=secnum.lua \
		--lua-filter=break-code.lua \
		--reference-doc=reference.odt \
		--metadata title="$(TITLE)" \
		--metadata author="$(AUTHOR)" \
		--metadata lang="$(LANG)"

%.html: %.md $(FILTERS) style.css
	sed '1d' $< | pandoc -o $@ \
		--standalone \
		--embed-resources \
		--toc --toc-depth=3 \
		--highlight-style=tango \
		--lua-filter=secnum.lua \
		--lua-filter=break-code.lua \
		--css=style.css \
		--metadata title="$(TITLE)" \
		--metadata author="$(AUTHOR)" \
		--metadata lang="$(LANG)"

%.txt: %.md $(FILTERS)
	{ printf '%s\n\n%s\n\n' "$(TITLE)" "$(AUTHOR)"; \
	  sed '1d' $< | pandoc \
		--toc --toc-depth=3 \
		--lua-filter=secnum.lua \
		--lua-filter=break-code.lua \
		--to=plain \
		--metadata title="$(TITLE)" \
		--metadata author="$(AUTHOR)" \
		--metadata lang="$(LANG)"; \
	} > $@

%.jkl.md: %.md $(FILTERS)
	{ printf '%s\n' '---' \
		"title: \"$(TITLE)\"" \
		'comments: true' \
		'categories: [kernel]' \
		'---' '' '* TOC' '{:toc}' ''; \
	  sed '1d' $< | pandoc \
		--lua-filter=secnum.lua \
		-t gfm+attributes \
		--metadata title="$(TITLE)" \
		--metadata author="$(AUTHOR)" \
		--metadata lang="$(LANG)"; \
	} > $@

install: $(JEKYLL)
	$(foreach f,$(JEKYLL),install -m 644 $(f) $(BLOG_DIR)/_posts/$(POST_DATE)-$(basename $(basename $(f))).md;)

all: pdf odt html txt
pdf: $(PDF) $(FILTERS) $(TEX_DEPS)
odt: $(ODT) $(FILTERS) reference.odt
html: $(HTML) $(FILTERS) style.css
txt: $(TXT) $(FILTERS)
jekyll: $(JEKYLL) $(FILTERS)

clean:
	rm -f $(PDF) $(ODT) $(HTML) $(TXT) $(JEKYLL)

.PHONY: all pdf odt html txt jekyll install clean
.DELETE_ON_ERROR:
