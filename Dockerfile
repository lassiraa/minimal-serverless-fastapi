FROM python:3.12-slim as build

# Set the working directory in the container
WORKDIR /app

# Install any necessary dependencies
RUN apt-get update && apt-get install -y binutils patchelf && rm -rf /var/lib/apt/lists/*

# Copy the requirements file to the working directory
COPY ./app/ .

# Install the Python packages listed in requirements.txt
RUN pip install -r requirements.txt --no-cache-dir
# Install packages required for the packaging process
RUN pip install pyinstaller staticx
# Package the FastAPI application into an executable binary
RUN pyinstaller main.py --onefile --name fastapi_backend

# Package additional necessary dependencies for the executable binary using staticx
WORKDIR /app/dist
RUN staticx --strip fastapi_backend fastapi_backend_app
RUN mkdir tmp

FROM scratch as runtime
ENTRYPOINT ["/app/dist/fastapi_backend_app"]
# Copy the AWS Lambda Web Adapter binary to the container
COPY --chmod=0755 --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.3 /lambda-adapter /opt/extensions/lambda-adapter
# Copy the FastAPI application binary to the container
COPY --chmod=0755 --from=build /app/dist/fastapi_backend_app /app/dist/fastapi_backend_app
COPY --chmod=0755 --from=build /app/dist/tmp /tmp
ENV PORT=8000