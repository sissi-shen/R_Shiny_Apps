# R_Shiny_Apps - Docker Deployment

This repository contains R Shiny applications that can be deployed using Docker. Below are the instructions for building Docker images and running the Shiny apps locally.

**Deployment Instructions**
1. Navigate to the Dockerfile Directory
Each Shiny app in this repository has its own Dockerfile. First, navigate to the directory of the app you'd like to deploy:
`cd path/to/your/app`
2. Build the Docker Image (Replace <image_name> with your preferred name for the image)
- For Linux systems: Run the following command in your terminal to build the Docker image:
  `docker build -t <image_name> . `
- For M-series Macs (Apple Silicon): If you're using an M-series Mac, add the platform specification to ensure compatibility:
  `docker build --platform linux/x86_64 -t <image_name> . `
3. Run the Docker Container
After the image is built, run the container and bind the host port to your local port 3838 (R shiny's default port):
`docker run -p 3838:3838 <image_name>`
4. Access the Shiny App
Once the container is running, open your web browser and navigate to: http://localhost:3838. You should see the Shiny app running on your local machine.


_Notes_: Each app has its own directory with a Dockerfile. Make sure you are in the correct directory for the app you'd like to deploy before building the image.

**Troubleshooting**:
1. If you encounter any issues, check Docker logs using: `docker logs <container_id>`
2. You can obtain the <container_id> by listing all running containers: `docker ps`

