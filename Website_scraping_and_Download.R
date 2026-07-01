#-----------------------------
# Install packages if needed
#-----------------------------
install.packages(c("rvest", "xml2", "stringr"))

library(rvest)
library(xml2)
library(stringr)

#-----------------------------
# Specify target website
#-----------------------------

url <- "https://public.envirodna.red/data/ED_1905CR35/manifest_2fa3b4e251a6a08d638978ffc23d66a6769d26a0da3fde9e31b9c258883b9a01.html"

#-----------------------------
# Read webpage
#-----------------------------

page <- read_html(url)

#-----------------------------
# Extract all links (href attributes)
#-----------------------------

links <- page |>
  html_elements("a") |>
  html_attr("href")

# Remove empty values
links <- links[!is.na(links) & links != ""]

# Convert to absolute URLs
links <- xml2::url_absolute(links, url)

# DEBUG: check what we actually have
cat("All extracted links:\n")
print(head(links, 50))

# Match gz/json anywhere in the URL (not just end)
target_links <- links[
  str_detect(links, "\\.gz(\\?.*)?$|\\.json(\\?.*)?$")
]

cat("\nFiltered download links:\n")
print(target_links)

#-----------------------------
# Download the data to a directory
#-----------------------------
download_dir <- "eDNA_raw_data"
dir.create(download_dir, showWarnings = FALSE)

for (link in target_links) {
  
  # remove query string for filename safety
  clean_link <- strsplit(link, "\\?")[[1]][1]
  file_name <- basename(clean_link)
  
  dest_file <- file.path(download_dir, file_name)
  
  cat("Downloading:", file_name, "\n")
  
  tryCatch({
    download.file(
      url = link,
      destfile = dest_file,
      mode = "wb",
      quiet = FALSE
    )
  }, error = function(e) {
    cat("FAILED:", link, "\n")
    cat("Reason:", e$message, "\n")
  })
}

cat("Done.\n")
