

<!-- README.md is generated from README.qmd. Please edit that file -->

<a href="https://umccr.github.io/nemo"><img src="man/figures/logo.png" alt="logo" align="left" height="100" /></a>

# Tidy and Explore Bioinformatic Pipeline Outputs

[![conda-latest1](https://anaconda.org/umccr/r-nemo/badges/latest_release_date.svg "Conda Latest Release")](https://anaconda.org/umccr/r-nemo)
[![gha](https://github.com/umccr/nemo/actions/workflows/deploy.yaml/badge.svg "GitHub Actions")](https://github.com/umccr/nemo/actions/workflows/deploy.yaml)

- 📚 Docs: <https://umccr.github.io/nemo>

## 🍕 Installation

Using {remotes} directly from GitHub:

``` r
install.packages("remotes")
remotes::install_github("umccr/nemo") # latest main commit
remotes::install_github("umccr/nemo@v0.0.0.9000") # released version
```

Alternatively:

- conda package: <https://anaconda.org/umccr/r-nemo>
- Docker image: <https://github.com/umccr/nemo/pkgs/container/nemo>

For more details see:
<https://umccr.github.io/nemo/articles/installation>

## 🌀 CLI

A `nemo.R` command line interface is available for convenience.

- If you’re using the conda package, the `nemo.R` command will already
  be available inside the activated conda environment.
- If you’re *not* using the conda package, you need to export the
  `nemo/inst/cli/` directory to your `PATH` in order to use `nemo.R`.

``` bash
nemo_cli=$(Rscript -e 'x = system.file("cli", package = "nemo"); cat(x, "\n")' | xargs)
export PATH="${nemo_cli}:${PATH}"
```

``` bash
# TODO
nemo_cli=$(Rscript -e 'x = system.file("cli", package = "nemo"); cat(x, "\n")' | xargs)
export PATH="${nemo_cli}:${PATH}"

echo "$ nemo.R --version" & nemo.R --version
echo ""
echo "#-----------------------------------#"
echo "$ nemo.R --help" & nemo.R --help
echo "'"
```
