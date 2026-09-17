# build_taxonomic_tree.R
#
# Base-R port of build_taxonomic_tree.py -- draws a taxonomic tree (Order ->
# Suborder -> Clade -> Superfamily -> Family -> Genus -> Species), with
# background color bands by whatever "group" column you give it, from a CSV
# shaped like species_groups_moderate.csv.
#
# USAGE (in RStudio):
#   source("build_taxonomic_tree.R")
#   build_taxonomic_tree("species_groups_moderate.csv", "my_tree.png")
#
#   # optional custom title (two lines):
#   build_taxonomic_tree("species_groups_moderate.csv", "my_tree.png",
#                         title1 = "My Custom Title", title2 = "n = 72")
#
# REQUIREMENTS: base R only -- no packages to install.
#
# INPUT CSV must have these columns (exactly what species_groups_moderate*.csv
# has): common_name, scientific_name, order, family, genus, group_key,
# group_name
# Row order in the CSV IS the phylogenetic sequence used to lay out the tree --
# don't re-sort the rows (e.g. alphabetically) before running this, or the
# tree will misrepresent relatedness. Editing group_key/group_name (like you
# did) is fine and expected -- the script doesn't assume any particular
# grouping, it just draws whatever groups are in the file. If your edited
# groups aren't contiguous in the CSV (e.g. you pulled a few species from one
# part of the list into a group that lives elsewhere), that group will simply
# render as more than one colored band, tied together by matching color and
# one legend entry -- that's expected, not a bug.

# ---- Higher-level classification within Passeriformes ---------------------
# Keyed by the exact family string used throughout this project. Based on
# modern phylogenomics (e.g. Oliveros et al. 2019): Vireonidae + Corvidae =
# core Corvoidea ("Corvides"); Tyrannidae = suboscine, outside the oscine
# radiation entirely; the rest follows the Passerida superfamily sequence
# (Paroidea / Sylvioidea / Certhioidea / Muscicapoidea / Passeroidea).


#setwd('/Users/rosestewart/Documents/R/eBird/01 Active_Migration Experiment/Sept Cleaning_WIP/data/Taxonomy-ish_Groupings')

.PASSERIFORMES_CLASSIFICATION <- list(
  "Tyrannidae (Tyrant Flycatchers)" =
    list(suborder = "Tyranni (suboscines)"),
  "Vireonidae (Vireos, Shrike-Babblers, and Erpornis)" =
    list(suborder = "Passeri (oscines)", clade = "Corvides"),
  "Corvidae (Crows, Jays, and Magpies)" =
    list(suborder = "Passeri (oscines)", clade = "Corvides"),
  "Paridae (Tits, Chickadees, and Titmice)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Paroidea"),
  "Hirundinidae (Swallows)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Sylvioidea"),
  "Sittidae (Nuthatches)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Certhioidea"),
  "Certhiidae (Treecreepers)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Certhioidea"),
  "Polioptilidae (Gnatcatchers)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Certhioidea"),
  "Troglodytidae (Wrens)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Certhioidea"),
  "Sturnidae (Starlings)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Muscicapoidea"),
  "Mimidae (Mockingbirds and Thrashers)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Muscicapoidea"),
  "Turdidae (Thrushes and Allies)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Muscicapoidea"),
  "Bombycillidae (Waxwings)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Muscicapoidea"),
  "Fringillidae (Finches, Euphonias, and Allies)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Passeroidea"),
  "Passerellidae (New World Sparrows)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Passeroidea"),
  "Icteridae (Troupials and Allies)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Passeroidea"),
  "Parulidae (New World Warblers)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Passeroidea"),
  "Cardinalidae (Cardinals and Allies)" =
    list(suborder = "Passeri (oscines)", clade = "Passerida", superfamily = "Passeroidea")
)

.RANK_X <- c(Order = 0.0, Suborder = 1.5, Clade = 3.0, Superfamily = 4.5, Family = 6.3, Genus = 7.9)
.X_SPECIES <- 9.3
.LABEL_X <- 9.55
.BAND_X0 <- -4.6

.RANK_STYLE <- list(
  Order       = list(fontsize = 1.05, color = "#1f3a5f", font = 2, yoff = 0.34),
  Suborder    = list(fontsize = 0.98, color = "#0f6b5c", font = 2, yoff = 0.26),
  Clade       = list(fontsize = 0.94, color = "#7a3b8c", font = 2, yoff = 0.18),
  Superfamily = list(fontsize = 0.90, color = "#a83232", font = 4, yoff = 0.10),
  Family      = list(fontsize = 0.88, color = "#6b4226", font = 3, yoff = 0.0)
)

.PALETTE_CYCLE <- if (requireNamespace("RColorBrewer", quietly = TRUE)) {
  RColorBrewer::brewer.pal(8, "Dark2")
} else {
  c("#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E", "#E6AB02", "#A6761D", "#666666")
}

.short_family <- function(fam) {
  m <- regmatches(fam, regexec("^(.*?)\\s*\\((.*)\\)$", fam))[[1]]
  if (length(m) == 3) m[3] else fam
}

.get_path <- function(rec) {
  path <- list(list(label = "Order", name = rec$order))
  info <- .PASSERIFORMES_CLASSIFICATION[[rec$family]]
  if (!is.null(info)) {
    if (!is.null(info$suborder))    path[[length(path) + 1]] <- list(label = "Suborder", name = info$suborder)
    if (!is.null(info$clade))       path[[length(path) + 1]] <- list(label = "Clade", name = info$clade)
    if (!is.null(info$superfamily)) path[[length(path) + 1]] <- list(label = "Superfamily", name = info$superfamily)
  }
  path[[length(path) + 1]] <- list(label = "Family", name = rec$family)
  path[[length(path) + 1]] <- list(label = "Genus", name = rec$genus)
  path
}

.insert_path <- function(root, path, species) {
  key <- paste(path[[1]]$label, path[[1]]$name, sep = "||")
  if (length(path) == 1) {
    if (is.null(root[[key]])) root[[key]] <- character(0)
    root[[key]] <- c(root[[key]], species)
  } else {
    if (is.null(root[[key]])) root[[key]] <- list()
    root[[key]] <- .insert_path(root[[key]], path[-1], species)
  }
  root
}

build_taxonomic_tree <- function(in_csv, out_png, title1 = NULL, title2 = NULL) {

  df <- read.csv(in_csv, stringsAsFactors = FALSE, encoding = "UTF-8")
  required_cols <- c("common_name", "order", "family", "genus", "group_key", "group_name")
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop("Input CSV is missing required column(s): ", paste(missing_cols, collapse = ", "))
  }
  n <- nrow(df)
  if (n == 0) stop("No rows found in ", in_csv)

  leaf_y <- setNames(rev(seq_len(n)) - 1, df$common_name)

  # ---- build the nested tree and insert every species ----
  root <- list()
  for (i in seq_len(n)) {
    rec <- list(order = df$order[i], family = df$family[i], genus = df$genus[i])
    path <- .get_path(rec)
    root <- .insert_path(root, path, df$common_name[i])
  }

  # ---- recursive layout: fills env$segments / env$labels, returns node y ----
  env <- new.env()
  env$segments <- vector("list", 0)
  env$labels <- vector("list", 0)

  layout_genus <- function(species_vec, genus_x) {
    ys <- leaf_y[species_vec]
    gy <- mean(ys)
    for (i in seq_along(species_vec)) {
      sy <- ys[i]
      env$segments[[length(env$segments) + 1]] <- c(genus_x, gy, genus_x, sy)
      env$segments[[length(env$segments) + 1]] <- c(genus_x, sy, .X_SPECIES, sy)
      env$labels[[length(env$labels) + 1]] <- list(x = .LABEL_X, y = sy, text = species_vec[i], kind = "species")
    }
    gy
  }

  layout <- function(node, node_x) {
    keys <- names(node)
    child_ys <- numeric(length(keys))
    for (i in seq_along(keys)) {
      parts <- strsplit(keys[i], "\\|\\|")[[1]]
      label <- parts[1]
      child_x <- .RANK_X[[label]]
      value <- node[[keys[i]]]
      child_ys[i] <- if (is.character(value)) layout_genus(value, child_x) else layout(value, child_x)
    }
    node_y <- mean(child_ys)
    for (i in seq_along(keys)) {
      parts <- strsplit(keys[i], "\\|\\|")[[1]]
      label <- parts[1]; name <- parts[2]
      child_x <- .RANK_X[[label]]
      child_y <- child_ys[i]
      env$segments[[length(env$segments) + 1]] <- c(node_x, node_y, node_x, child_y)
      env$segments[[length(env$segments) + 1]] <- c(node_x, child_y, child_x, child_y)
      if (label != "Genus") {
        style <- .RANK_STYLE[[label]]
        text <- if (label == "Family") .short_family(name) else name
        env$labels[[length(env$labels) + 1]] <- list(x = child_x - 0.12, y = child_y + style$yoff,
                                                       text = text, kind = label)
      }
    }
    node_y
  }

  layout(root, -1.6)

  # ---- color bands: contiguous runs of group_key in CSV row order ----
  group_levels <- unique(df$group_key)
  group_name_of <- setNames(df$group_name[match(group_levels, df$group_key)], group_levels)
  palette <- setNames(.PALETTE_CYCLE[(seq_along(group_levels) - 1) %% length(.PALETTE_CYCLE) + 1], group_levels)
  sizes <- table(df$group_key)[group_levels]

  bands <- list()
  cur_key <- NULL; cur_ys <- c()
  for (i in seq_len(n)) {
    k <- df$group_key[i]; y <- leaf_y[[df$common_name[i]]]
    if (!identical(k, cur_key)) {
      if (!is.null(cur_key)) bands[[length(bands) + 1]] <- list(key = cur_key, ys = cur_ys)
      cur_key <- k; cur_ys <- y
    } else {
      cur_ys <- c(cur_ys, y)
    }
  }
  bands[[length(bands) + 1]] <- list(key = cur_key, ys = cur_ys)

  # ---- draw ----
  fig_h_in <- max(14, n * 0.235)
  png(out_png, width = 20.5, height = fig_h_in, units = "in", res = 220, bg = "white")
  on.exit(dev.off(), add = TRUE)

  xlim <- c(.BAND_X0 - 0.1, .LABEL_X + 5.5)   # extra room on the right for the legend
  ylim <- c(-1.5, n + 0.5)
  par(mar = c(1, 1, 4, 1))
  plot(NA, xlim = xlim, ylim = ylim, axes = FALSE, xlab = "", ylab = "", xaxs = "i", yaxs = "i")

  for (b in bands) {
    y0 <- min(b$ys) - 0.5; y1 <- max(b$ys) + 0.5
    rect(xlim[1], y0, .LABEL_X + 3.9, y1, col = adjustcolor(palette[[b$key]], alpha.f = 0.75), border = NA)
    text(.BAND_X0 + 0.1, (y0 + y1) / 2, labels = paste0("n=", length(b$ys)),
         adj = c(0, 0.5), cex = 0.75, font = 2, col = "#333333")
  }

  for (seg in env$segments) {
    segments(seg[1], seg[2], seg[3], seg[4], col = "#3b5a48", lwd = 1.1)
  }

  for (lab in env$labels) {
    if (lab$kind == "species") {
      text(lab$x, lab$y, labels = lab$text, adj = c(0, 0.5), cex = 0.72, col = "#1a1a1a")
    } else {
      style <- .RANK_STYLE[[lab$kind]]
      text(lab$x, lab$y, labels = lab$text, adj = c(1, if (lab$kind == "Family") 0.5 else 0),
           cex = style$fontsize * 0.72, col = style$color, font = style$font)
    }
  }

  t1 <- if (is.null(title1)) "Species Grouped by Relatedness" else title1
  t2 <- if (is.null(title2)) paste0("n=", n, " -- groups as edited in the input CSV") else title2
  mtext(t1, side = 3, line = 2.2, cex = 1.15, font = 2)
  mtext(t2, side = 3, line = 1.0, cex = 0.85)

  legend_labels <- paste0(group_name_of[group_levels], " (n=", as.integer(sizes), ")")
  legend("topright", inset = c(-0.001, 0), legend = legend_labels,
         fill = adjustcolor(unname(palette[group_levels]), alpha.f = 0.75),
         title = "Groups", bty = "o", cex = 0.75, xpd = TRUE)

  message("Wrote ", out_png, " (", n, " species, ", length(group_levels), " groups)")
  invisible(NULL)
}

# ---- allow `Rscript build_taxonomic_tree.R in.csv out.png ["t1" "t2"]` too ----
if (sys.nframe() == 0 && !interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) >= 2) {
    do.call(build_taxonomic_tree, as.list(args))
  }
}
