FROM python:3.9-alpine3.13
# It is best practice to add the name of the maintainer to the Dockerfile
# This helps in identifying who is responsible for the image
LABEL maintainer="lk989"


# this env is recommeded to avoid buffering of the output
# This is useful for logging purposes, especially when running in a container
# It ensures that the output is sent directly to the terminal or log file
# without being buffered, which can help in debugging and monitoring
ENV PYTHONUNBUFFERED=1


# Install the required packages from the requirements.txt file
COPY ./requirements.txt /tmp/requirements.txt
# Install the required packages from the requirements.dev.txt file
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# Copy the application code into the container
COPY ./app /app
# Set the working directory to /app
WORKDIR /app
# Expose port 8000 for the application to listen on
EXPOSE 8000


ARG DEV=false
# Running all the commands in a single RUN statement to reduce the number of layers in the image

# Create a virtual environment in the /p directory
RUN python -m venv /p && \
    # Install the required packages in the virtual environment
    /p/bin/pip install --upgrade pip && \
    /p/bin/pip install -r /tmp/requirements.txt && \
    # If the DEV argument is true, install the development requirements
    if [ $DEV = "true" ]; then \
        /p/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    # remove the temp file to keep image light
    rm -rf /tmp && \
    # create user || it is a good practice to run the app as a non-root user
    adduser \
        # create a user with no password
        --disabled-password \
        # create a user with no home directory
        --no-create-home \
        # name the user
        django-user

ENV PATH="/p/bin:$PATH"

USER django-user