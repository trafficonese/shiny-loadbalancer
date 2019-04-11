# Shiny App for for Load Balancing

## TODO - better matrices?

setwd(LOGPATH)

while (TRUE) {
    dat <- tryCatch(readLines(pipe("top -n 1 -b -u shiny","r")), error = function(e) NA)
    id <- grep("R *$", dat)
    Names <- strsplit(gsub("^ +|%|\\+", "", dat[7]), " +")[[1]]

    if (length(id) > 0) {
        # 'top' data frame;
        L <- strsplit(gsub("^ *", "", dat[id]), " +")
        dat <- data.frame(matrix(unlist(L), ncol = 12, byrow = T), stringsAsFactors = FALSE)
        names(dat) <- Names

        ## TODO - Why is Time/CPU/MEM needed?
        dat <- data.frame(Time = Sys.time(), dat[, -ncol(dat)], usr = NA, app = NA, stringsAsFactors = FALSE)
        dat$CPU <- as.numeric(gsub(pattern = ",", ".", dat$CPU, fixed = T))
        dat$MEM <- as.numeric(gsub(pattern = ",", ".", dat$MEM, fixed = T))


        # Check if connection number changed;
        for (i in 1:length(dat$PID)) {
            PID <- dat$PID[i]

            ### PASSWORD NEEDED ?!?!
            netstat <- readLines(pipe(paste("sudo netstat -p | grep", PID), "r"))
            lsof <- readLines(pipe(paste0("sudo lsof -p ", PID, " | grep ",PATH),"r"))


            dat$usr[i] <- tryCatch(length(grep(conn, netstat) & grep("tcp", netstat)),
                                   error = function(e) NA)
            dat$app[i] <- tryCatch(regmatches(lsof, regexec(paste0(PATH, "(.*)"), lsof))[[1]][2],
                                   error = function(e) NA)
        }
        dat <- dat[, c("app", "usr")]
    } else {
        dat <- data.frame(app = "app", usr = 0)
    }

    write.table(dat, file = LOGFILE, row.names=F)
}
