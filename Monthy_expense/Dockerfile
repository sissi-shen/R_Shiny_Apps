# Base R Shiny image
FROM rocker/shiny

# Make a directory in the container to hold the app
RUN mkdir /shiny-app

# Install R dependencies
RUN R -e "install.packages(c('dplyr', 'ggplot2', 'shiny'))"

# Copy the Shiny app code
COPY . /shiny-app

# Expose the application port (3838 is default for Shiny)
EXPOSE 3838

# Run the R Shiny app
CMD ["R", "-e", "shiny::runApp('/shiny-app/app.R', host='0.0.0.0', port=3838)"]
