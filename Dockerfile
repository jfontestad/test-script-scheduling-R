# Use an official R runtime as a parent image
FROM r-base

# Install system libraries required by R and renv
RUN apt-get update -qq \
  && apt-get -y --no-install-recommends install \
    libcurl4-openssl-dev \
    libicu-dev \
    libsodium-dev \
    libssl-dev \
    make

# Set the working directory in the container to /app
WORKDIR /app

# Assuming your renv.lock file is at the root of your project
# Copy the renv.lock file into the container at /app
COPY renv.lock /app/

# Install renv and restore the project library
RUN R -e "install.packages('renv', repos = 'http://cran.rstudio.com/')"
RUN R -e "renv::restore()"

# Copy the R_prod directory contents into the container at /app/R_prod
COPY R_prod/ /app/R_prod

# Make sure the script is executable
RUN chmod +x /app/R_prod/script_data_extraction.R

# Run the script when the container launches
CMD ["Rscript", "R_prod/script_data_extraction.R"]