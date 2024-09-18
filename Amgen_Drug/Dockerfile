# Use the rocker/shiny image as the base
FROM rocker/shiny

# Make a directory in the container to hold the app
RUN mkdir /shiny-app

# Install required R packages
RUN R -e "install.packages(c('shiny', 'dplyr', 'DBI', 'RSQLite'))"

# Copy the Shiny app code
COPY . /shiny-app

# Expose port 3838 for the Shiny app
EXPOSE 3838

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/shiny-app/app.R', host='0.0.0.0', port=3838)"]

