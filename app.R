library(shiny)

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("CS130(0) A/B Testing Data Cleaner"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("uploaded_file", "Upload your mylog.txt file",
                accept = c("text/plain",
                           ".txt")),
      # Button
      downloadButton("downloadData", "Download your cleaned data!")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Data file ----
      tableOutput("contents")
      
    )
    
  )
)

mylog = NULL

# Define server logic to read selected file ----
server <- function(input, output) {

  output$contents <- renderTable({
    
    # input$uploaded_file will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$uploaded_file) # check if file has been uploaded
    
    # read data
    mylog <<- read.csv(input$uploaded_file$datapath, stringsAsFactors = FALSE)
    names(mylog) <<- "line"
    
    # create variables
    library(tidyr)
    mylog <<- separate(mylog, line, c("time", "app", "ab_testing", "version", "page_load_time", "click_time", "clicked_HTML_element_id", "session_ID"), " ")
    mylog <<- mylog[c(-1, -2, -3)]
    
    # format timestamp
    library(stringr)
    #mylog$time <<- str_replace(mylog$time, "T", " ")
    #mylog$time <<- str_replace(mylog$time, fixed("+00:00"), "")
    #op <- options(digits.secs = 6)
    #mylog$time <<- as.POSIXct(mylog$time)
    #mylog$time <<- as.numeric(mylog$time)

    return(mylog)
    
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      name <- substr(input$uploaded_file, 1, nchar(input$uploaded_file)-4)
      paste(name, "_clean.csv", sep = "")
    },
    content = function(file) {
      write.csv(mylog, file)
    },
    contentType="text/csv"
    )
  
}
# Run the app ----
shinyApp(ui, server)
