# create redirect URL
# appnames: vector of shiny apps user are distributed to
# baseurl: Full URL of the directory with shiny apps, trailing slash must be added

makeRedirect <- function(appnames, baseurl) {
  CPU <- read.table(paste0(LOGPATH,"/", LOGFILE), stringsAsFactors = F)
  App <- data.frame(app = appnames)
  App <- merge(App, CPU, all.x = TRUE)
  App$usr[which(is.na(App$usr))] <- 0
  return(paste(baseurl, App$app[which.min(App$usr)],"/", sep = ""))
}

# list only dirs
list_app_mirrors <- function(path=".", pattern=NULL, all.dirs=FALSE,
                             full.names=FALSE, ignore.case=FALSE) {
  all <- list.files(path, pattern, all.dirs,
           full.names, recursive=FALSE, ignore.case)
  # all[file.info(paste0(path,"/",all))$isdir]
  all[file.info(paste0(path, all))$isdir]
}

# returns current appname
pwd <- function() {
  path <- strsplit(getwd(), "/")
  return(path[[1]][length(path[[1]])])
}

shinyServer(function(input, output, session) {
  output$link <- renderUI({

    path = getwd()
    # path = "../"
    pattern = paste0("^",pwd(),"_[0-9]")
    appnames = list_app_mirrors(path = path, pattern = pattern)

    list(
         # Input that holds the redirect URL
         textInput(inputId = "url", label = "",
                   value = makeRedirect(appnames = appnames, baseurl = "")),
         # JavaScript for redirecting
         tags$script(type="text/javascript", src = "shiny-redirect.js")
    )
  })
})

