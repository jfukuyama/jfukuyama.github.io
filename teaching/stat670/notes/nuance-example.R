## copied from https://github.com/kjhealy/nuance/blob/master/nuance.r
library(gtable)
library(tidyverse)
library(lubridate)
library(stringr)
library(splines)

fields <- list("Sociology", "Economics", "Politics", "Anthropology", "History", "Philosophy",
               "Psychology")

journals <- c("AER", "ASR", "AJPS", "APSR", "AJS", "Demography", "JOP", "JPE", "QJE",
              "SF")

jl.names <- c("Amer. Economic Rev.", "Amer. Sociological Rev.", "Amer. Jl of Political Science",
              "Amer. Political Science Rev.", "Amer. Jl Sociology", "Demography", "Jl of Politics",
              "Jl of Political Economy", "Quarterly Jl of Economics", "Social Forces")

soc.journals <- c("ASR", "AJS", "SF", "ST", "TS")

soc.names <- c("ASR", "AJS", "Social Forces", "Sociological Theory", "Theory and Society")

### Generates keyword data frame for a single keyword in a given unit
proc.unit <- function(unit = "Sociology", subdir = "terms", keyword = "nuance", ...) {
  
  ### Fix for AJS misclassifications
  fix.ajs <- function(x, ...) {
    
    ## First get all the AJS articles with the term in them
    fname <- file.path("data", "manual", paste0("ajs-control-", keyword, "-cites.csv"))
    ajs.df <- read.csv(fname, header = TRUE, stringsAsFactors = FALSE)
    
    ajs.df <- ajs.df %>% select(id, journaltitle, pubdate, pagerange)
    
    ajs.df$pubdate <- as.Date(ajs.df$pubdate)
    ajs.df$year <- year(ajs.df$pubdate)
    ajs.df$journaltitle <- factor(ajs.df$journaltitle)
    
    pages <- clean.pages(ajs.df$pagerange)
    
    ajs.df$startpage <- pages$startpage
    ajs.df$endpage <- pages$endpage
    ajs.df$length <- pages$length
    
    ## Tabulate how many 'articles' are actually book reviews
    tab.bookreviews <- ajs.df %>% group_by(year) %>% filter(length < 4) %>% group_by(year) %>%
      tally() %>% filter(year %in% c(1997:1999))
    colnames(tab.bookreviews) <- c("year", "bookrev.n")
    
    ## Tabulate how many real articles have the keyword
    tab.keyword <- ajs.df %>% group_by(year) %>% filter(length > 3) %>% tally() %>%
      filter(year %in% c(1997:1999))
    colnames(tab.keyword) <- c("year", "keyword.n")
    
    ## Uncorrected AJS article count for 97-99
    ajs.ac <- read.csv("data/article-counts/ac-AJS.csv")
    colnames(ajs.ac) <- c("year", "article.n")
    tab.uncorrected <- ajs.ac %>% filter(year %in% c(1997:1999))
    
    correct.counts <- merge(tab.uncorrected, tab.bookreviews)
    correct.counts$corr.article.n <- correct.counts$article.n - correct.counts$bookrev.n
    
    correct.counts <- merge(correct.counts, tab.keyword)
    
    x[, "articles"][x$year %in% correct.counts$year] <- correct.counts$corr.article.n
    x[, keyword][x$year %in% correct.counts$year] <- correct.counts$keyword.n
    return(x)
  }
  
  fn.articles <- file.path("data", "article-counts", paste0("ac-", unit, ".csv"))
  fn.term <- file.path("data", subdir, paste0(keyword, "-", unit, ".csv"))
  
  message("Term file path is ", fn.term, "; keyword is ", keyword)
  
  tmp1 <- read.csv(fn.articles)
  colnames(tmp1) <- c("year", "articles")
  
  tmp2 <- read.csv(fn.term)
  colnames(tmp2) <- c("year", keyword)
  
  data <- merge(tmp1, tmp2, all = TRUE)
  
  if (unit == "AJS") {
    data <- fix.ajs(data, ...)
  }
  
  
  ind <- which(is.na(data[, keyword]))
  data[, keyword][ind] <- 0
  data$rate <- round((data[, keyword]/data$articles), 3)
  data$unit <- unit
  return(data)
}

### raw pagerange column to df with start and end pages as numbers fixes page
### numbering inconsistency
clean.pages <- function(raw.pages) {
  pages <- str_replace_all(raw.pages, "S", "")  # supplements
  pages <- str_replace(pages, "pp. ", "")
  pages <- str_split_fixed(pages, "-", 2)
  pages <- data.frame(pages, stringsAsFactors = FALSE)
  colnames(pages) <- c("startpage", "endpage")
  
  ## AJS is sometimes inconsistent with page ranges e.g. saying 1125-27 instead of
  ## 1125-1127
  
  ## length(endpage) should not be shorter than length(startpage)
  p.start <- str_length(pages$startpage)
  p.end <- str_length(pages$endpage)
  p.diff <- p.start - p.end
  ind <- p.diff > 0  ## bad page ranges
  
  ## figure out where to cut the string
  s.width <- str_length(pages[ind, "startpage"])
  e.width <- str_length(pages[ind, "endpage"])
  cut.point <- s.width - e.width
  
  ## correct numeric prefix
  x <- substr(pages[ind, "startpage"], 1, cut.point)
  new.end <- paste0(x, pages[ind, "endpage"])
  
  pages[ind, "endpage"] <- new.end
  pages <- apply(pages, 2, as.numeric)
  pages <- data.frame(pages)
  pages$length <- pages$endpage - (pages$startpage - 1)
  return(pages)
}

### Apply proc.unit() to a vector of unit names for a given keyword, clean it up,
### and calculate the relative rate for the keyword
make.keyword.df <- function(unit.names, full.names = NULL, new.labels = FALSE, keyword = "nuance",
                            subdir = "manual", ...) {
  
  out <- lapply(unit.names, proc.unit, keyword = keyword, subdir = subdir, ...)
  data <- bind_rows(out)
  
  if (new.labels == TRUE) {
    lab.lookup <- data.frame(unit.names, full.names)
    colnames(lab.lookup) <- c("old", "new")
    ind <- match(data$unit, lab.lookup$old)
    data$longlab <- factor(lab.lookup$new[ind])
  }
  
  ### Reorder for labeling purposes
  unit.tab <- data %>% group_by(unit) %>% filter(year > 2001) %>% summarize(Med = median(rate)) %>%
    ungroup() %>% arrange(desc(Med))
  
  data$unit <- factor(data$unit, levels = unit.tab$unit, ordered = TRUE)
  
  if (new.labels == TRUE) {
    ind <- match(unit.tab$unit, lab.lookup$old)
    data$longlab <- factor(data$longlab, levels = lab.lookup$new[ind], ordered = TRUE)
  }
  
  data.total <- proc.unit("Total", keyword = keyword, subdir = subdir, ...)
  colnames(data.total) <- c("year", "total.articles", paste0("total.", keyword),
                            "total.rate", "total")
  
  ## Calculate difference relative to the base rate
  data <- merge(data, data.total)
  data$tmp_rk <- data$rate - data$total.rate
  nv <- colnames(data)[1:(ncol(data) - 1)]
  colnames(data) <- c(nv, paste0("relative.", keyword))
  
  return(data)
}

data.fields <- make.keyword.df(unit.names = fields, subdir = "terms")
ggplot(data.fields, aes(x = unit, y = rate)) + geom_boxplot()
