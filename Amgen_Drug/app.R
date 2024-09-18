# Load required libraries
library(shiny)
library(dplyr)
library(DBI)
library(RSQLite)

# Load CSV into SQLite database for SQL querying
con <- dbConnect(RSQLite::SQLite(), ":memory:")
amgen_drugs <- read.csv("Amgen_Drugs.csv")
dbWriteTable(con, "amgen_drugs", amgen_drugs)

# Define UI
ui <- navbarPage(
    title = "Amgen Drug Information Lookup",
    theme = bslib::bs_theme(bootswatch = "cerulean"),

    # Main tab panel
    tabPanel("Drug Lookup",
             sidebarLayout(
                 sidebarPanel(
                     textInput("drug_name", "Enter Drug Name:", ""),
                     selectInput("prescription_info", "Select Prescription Information:",
                                 choices = c("All", "Indications_and_Usage", "Dosage_and_Administration",
                                             "Dosage_Forms_and_Strengths", "Contradictions", "Warnings_and_Precautions",
                                             "Adverse_Reactions", "Drug_Interactions", "Use_in_Specific_Populations")),
                     actionButton("submit", "Submit")
                 ),
                 mainPanel(
                     htmlOutput("drug_info_table")
                 )
             )
    )
)

# Define Server
server <- function(input, output) {

    observeEvent(input$submit, {
        drug_name <- tolower(input$drug_name)  # Make drug name case-insensitive
        prescription_info <- input$prescription_info

        # SQL queries to extract info
        query <- if (prescription_info == "All") {
            paste0("SELECT Indications_and_Usage, Dosage_and_Administration,
                           Dosage_Forms_and_Strengths, Contradictions,
                           Warnings_and_Precautions, Adverse_Reactions, Drug_Interactions,
                           Use_in_Specific_Populations
                    FROM amgen_drugs
                    WHERE LOWER(Drug_Names) = '", drug_name, "'")
        } else {
            paste0("SELECT ", prescription_info, "
                   FROM amgen_drugs
                   WHERE LOWER(Drug_Names) = '", drug_name, "'")
        }

        output$drug_info_table <- renderUI({
            result <- dbGetQuery(con, query)

            if (nrow(result) == 0) {
                HTML("<p style='color:red;'>No data found for the specified drug.</p>")
            } else {
                if (prescription_info == "All") {
                    # If "All" is selected, display all the columns with headers
                    html_content <- ""
                    for (col_name in colnames(result)) {
                        col_content <- gsub("- ", "<br>- ", result[[col_name]])
                        html_content <- paste0(html_content, "<h5>", col_name, "</h5><p>", col_content, "</p><br>")
                    }
                } else {
                    # Display only the selected column
                    col_content <- gsub("- ", "<br>- ", result[[1, 1]])
                    html_content <- paste0("<h5>", prescription_info, "</h5><p>", col_content, "</p>")
                }


                HTML(html_content)
            }
        })

    })
}

# Run the app
shinyApp(ui = ui, server = server)

