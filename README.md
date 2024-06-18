# Build the image and deploy to lambda by running the following commands

-   `docker build -t fastapi .`
-   `aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin {ECR_URI}`
-   `docker tag fastapi {ECR_URI}/{ECR_REPOSITORY}`
-   `docker push {ECR_URI}/{ECR_REPOSITORY}`
-   `aws lambda create-function --function-name {FUNCTION_NAME} --code ImageUri={ECR_URI}/{ECR_REPOSITORY}:latest --role -{ROLE_ARN} --package-type Image`
