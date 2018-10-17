# Build Stage
FROM microsoft/dotnet:2.1-sdk AS build-env

WORKDIR /generator

## Restore
COPY api/api.csproj ./api/
RUN dotnet restore api/api.csproj

COPY tests/tests.csproj ./tests/
RUN dotnet restore tests/tests.csproj

## Copy src
COPY . .

## Test
ENV TEAMCITY_PROJECT_NAME=fake
RUN dotnet test tests/tests.csproj

## Publish
RUN dotnet publish api/api.csproj -o /publish

# Runtime Stage
FROM microsoft/dotnet:2.1-aspnetcore-runtime
COPY --from=build-env ./publish ./publish
WORKDIR /publish
ENTRYPOINT [ "dotnet", "api.dll" ]