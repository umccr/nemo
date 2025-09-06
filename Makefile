readme-render:
	@quarto render README.qmd

air:
	@air format

pkgdown-build:
	@R -e "pkgdown::build_site()" --quiet --no-restore --no-save

readme-pkgdown: readme-render pkgdown-build

roxydoc:
	@R -e "devtools::document()" --quiet --no-restore --no-save

build:
	@R -e "pak::local_install(upgrade = FALSE)" --quiet --no-restore --no-save

