# --- Stage 1: The "Build" Stage ---
# We use a Node.js image to build our React app
FROM node:18-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first
# This leverages Docker's layer caching.
COPY package.json package-lock.json ./

# Install all dependencies
RUN npm install

# Copy the rest of our app's source code
COPY . .

# Run the 'npm run build' script to create the 'build' folder
RUN npm run build


# --- Stage 2: The "Production" Stage ---
# We use a lightweight Nginx server to serve our static files
FROM nginx:1.25-alpine

# Set the working directory for Nginx
WORKDIR /usr/share/nginx/html

# Clean out the default Nginx content
RUN rm -rf ./*

# Copy *only* the built files from the 'build' stage (Stage 1)
# This is the key to a small image!
COPY --from=build /app/build .

# Expose port 80 (the default Nginx port)
EXPOSE 80

# The command to start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]