## #!/usr/local/bin/Rscript

## Display information about the client connecting to this service: IP address, time, User Agent string
## This version is for basic testing of AWS Lambda and other hosting options
##
## Jon Meek - December 2022

RCSid <- '$Id: idproxy.R,v 1.3 2022/12/26 22:23:39 meekj Exp meekj $'

## https://www.rplumber.io/
## library(plumber) # Loaded from Rscript command line, or manually in R console when testing

##
## Initialization, logo data at bottom of this file
##

Sys.setenv(TZ="UTC") # Needed by idproxy time reporting

service_start_time <- Sys.time()
run_count <- 0

##
## Services code
##

#* Minimal test
#* @get /hello
#* @serializer html
function(){
  "<html><h1>hello world</h1></html>"
}

#* idproxy PoC - Default
#* @get /
#* @serializer html
function(req) {
    run_count  <<- run_count + 1 # Global variable, requires <<- here
    time_now   <- as.character(Sys.time())
    ip_address <- req$REMOTE_ADDR
    user_agent <- req$HTTP_USER_AGENT

    html_output <- '<html><h1>'
    html_output <- c(html_output, our_logo_img)
    html_output <- c(html_output, 'R/plumber idproxy</h1>')
    
    html_output <- c(html_output, '<p>You arrived from: ', ip_address, ' at ', time_now, 'UTC</p>')
    html_output <- c(html_output, '<p>Your User-Agent string is: ', user_agent, '</p>')

    html_output <- c(html_output, '</pre>')

    ## If we know where this address is located add it to the output
    ## ... bring netblockr code back later ...

    html_output <- c(html_output, '<p>Run count: ', run_count, '</p>')
    html_output <- c(html_output, '</html>')
    html_output <- paste(html_output, collapse = '\n') # Get it all in one string
    html_output
}

#* idproxy PoC - Include header data
#* @get /headers
#* @serializer html
function(req) {
    run_count  <<- run_count + 1
    time_now   <- as.character(Sys.time())
    ip_address <- req$REMOTE_ADDR
    user_agent <- req$HTTP_USER_AGENT

    req_names <- as.character(names(req))
    
    html_output <- '<html><h1>'
    html_output <- c(html_output, our_logo_img)
    html_output <- c(html_output, 'R/plumber idproxy</h1>')
    
    html_output <- c(html_output, '<p>You arrived from: ', ip_address, ' at ', time_now, 'UTC</p>')
    html_output <- c(html_output, '<p>Your User-Agent string is: ', user_agent, '</p>')

    html_output <- c(html_output, '<h3>Header names:</h3>')
    html_output <- c(html_output, '<pre>', req_names, '</pre>')

    html_output <- c(html_output, '<h3>Header values:</h3>')
    html_output <- c(html_output, '<pre>')
    for (req_name in req_names) {
        req_value <- req[[req_name]] # type 'environment', cannot coerce to vector of type 'character'
        html_output <- c(html_output, req_name, req_value, '---')
    }
    html_output <- c(html_output, '</pre>')

    html_output <- c(html_output, '<p>Run count: ', run_count, '</p>')
    html_output <- c(html_output, '<p>', RCSid,'</p>' )
    html_output <- c(html_output, '</html>')
    html_output <- paste(html_output, collapse = '\n') # Get it all in one string
    html_output
}

##
## Logo data
##

our_logo_img  <- '
<img style="width: 90px; height: 105px;" alt="Plumber Logo" src="data:image/png;base64,
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
MDQ6MDBmyqk7AAAAAElFTkSuQmCC">
'

notes <- r"(

R

library(plumber)

pr('~/lab/R/idproxy.R') %>% pr_run(port = 8000) # localhost only

pr('~/lab/R/idproxy.R') %>% pr_run(host = '0.0.0.0', port = 8000)

Test on wx1

rsy -v ~/lab/R/idproxy.R wx1:~/lab/R


Docker does:

pr <- plumber::plumb(file = 'idproxy.R', dir = '/home/meekj/lab/R')

args <- list(host = '0.0.0.0', port = 8000)

pr$setDocs(TRUE)

do.call(pr$run, args)



curl http://localhost:8000

)"

## /usr/local/R-4.2.2/bin/Rscript -e "library(plumber); pr('/home/meekj/lab/R/idproxy.R') %>% pr_run(port = 8082, host='0.0.0.0')"

