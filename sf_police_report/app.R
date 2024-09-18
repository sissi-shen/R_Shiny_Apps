# install.packages("DBI")
# install.packages("RPostgres")

library(shiny)
library(DBI)
library(RPostgres)

# Function to connect to PostgreSQL
connect_db <- function(user, host, dbname, password=NULL) {
    conn <- dbConnect(RPostgres::Postgres(),
                      dbname = dbname,
                      host = host,
                      user = user,
                      password = password)
    return(conn)
}

# Function to return distinct neighborhood and police district
# return_distinct_neighborhood_police_district <- function(conn, n=NULL) {
#     if (is.null(n)) {
#         query <- "SELECT DISTINCT neighborhood, police_district
#                   FROM location
#                   WHERE neighborhood IS NOT NULL
#                   ORDER BY neighborhood ASC, police_district ASC"
#     } else {
#         query <- paste0("SELECT DISTINCT neighborhood, police_district
#                      FROM location
#                      WHERE neighborhood IS NOT NULL
#                      ORDER BY neighborhood ASC, police_district ASC
#                      LIMIT ", n)
#     }
#     return(dbGetQuery(conn, query))
# }

# Function to return distinct time taken
# return_distinct_time_taken <- function(conn, n = NULL) {
#     if (is.null(n)) {
#         query <- "SELECT DISTINCT EXTRACT(DAY FROM (report_datetime - incident_datetime)) AS diff
#               FROM incident
#               ORDER BY diff DESC"
#     } else {
#         query <- paste0("SELECT DISTINCT EXTRACT(DAY FROM (report_datetime - incident_datetime)) AS diff
#                      FROM incident
#                      ORDER BY diff DESC
#                      LIMIT ", n)
#     }
#     return(dbGetQuery(conn, query))
# }

# Find the monthly count of incidents in a registered location
return_count_by_location_report_type_incident_description <- function(con, year, neighborhood) {
    query <- paste0("
    SELECT EXTRACT(YEAR FROM incident_datetime)::INTEGER AS year,
           EXTRACT(MONTH FROM incident_datetime)::INTEGER AS month,
           location.neighborhood,
           report_type.report_type_description,
           incident_type.incident_description,
           COUNT(*) AS count
    FROM incident
    JOIN location ON incident.longitude = location.longitude
                 AND incident.latitude = location.latitude
    JOIN report_type ON incident.report_type_code = report_type.report_type_code
    JOIN incident_type ON incident.incident_code = incident_type.incident_code
    WHERE EXTRACT(YEAR FROM incident_datetime)::INTEGER = ", year, "
      AND location.neighborhood = '", neighborhood, "'
    GROUP BY year, month, location.neighborhood,
             report_type.report_type_description,
             incident_type.incident_description
    ORDER BY count DESC, year, month, location.neighborhood,
             report_type.report_type_description,
             incident_type.incident_description
  ")

    dbGetQuery(con, query)
}


# Build the shiny app
ui <- fluidPage(
    titlePanel("San Francisco Police Report Lookup"),

    sidebarLayout(
        sidebarPanel(
            textInput("year", "Enter Year (for Year & Neighborhood) :", ""),
            textInput("neighborhood", "Enter Neighborhood (for Year & Neighborhood) :", ""),
            textInput("report_desc", "Report Type Description"),
            textInput("incident_substr", "Incident Substring"),
            actionButton("query", "Submit")
        ),

        mainPanel(
            tabsetPanel(
                tabPanel("Year & Neighborhood", tableOutput("year_neighborhood_table")),
                tabPanel("Incident Description", tableOutput("incident_desc_table")),
                tabPanel("Incidents with Substring", tableOutput("incident_substr_table"))
            )
        )
    )
)

# Set up the server
server <- function(input, output, session) {
    conn <- connect_db(user = "postgres", host = "localhost", dbname = "msds691_HW")

    # Render the year_neighborhood table
    observeEvent(input$query, {
        year <- input$year
        neighborhood <- input$neighborhood

        if (nchar(year) > 0 && nchar(neighborhood) > 0) {
            result <- return_count_by_location_report_type_incident_description(conn, year, neighborhood)

            output$year_neighborhood_table <- renderTable({
                result
            })
        }
    })

    # Render table for incident description
    output$incident_desc_table <- renderTable({
        desc <- input$report_desc
        if (nchar(desc) > 0) {
            query <- paste0("SELECT DISTINCT it.incident_description
                       FROM incident_type it
                       JOIN incident i ON it.incident_code = i.incident_code
                       JOIN report_type rt ON rt.report_type_code = i.report_type_code
                       WHERE LOWER(rt.report_type_description) ILIKE '%", desc, "%'
                       ORDER BY it.incident_description ASC")
            dbGetQuery(conn, query)
        }
    })

    # Render table for incidents with substring
    output$incident_substr_table <- renderTable({
        substr <- input$incident_substr
        if (nchar(substr) > 0) {
            query <- paste0("SELECT DISTINCT i.id, i.incident_datetime
                       FROM incident i
                       JOIN incident_type it ON i.incident_code = it.incident_code
                       WHERE LOWER(it.incident_description) ILIKE '%", substr, "%'
                       ORDER BY i.id ASC")
            dbGetQuery(conn, query)
        }
    })

}

shinyApp(ui, server)
