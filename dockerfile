# Use an official Python runtime as a base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file into the container
COPY requirements.txt .

# Install the dependencies from the requirements.txt
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Create a non-root user
RUN useradd --create-home appuser

# Give the user permissions to /app and /tmp
RUN chown -R appuser:appuser /app /tmp

# Copy the Python script into the container
COPY . .

# Set the default command to run the Python script
CMD ["python", "dm.py"]
