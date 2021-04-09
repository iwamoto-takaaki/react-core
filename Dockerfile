FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install -y nodejs

# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install -y nodejs
WORKDIR /source
COPY . .

# copy csproj and restore as distinct layers
COPY *.csproj .
RUN dotnet restore "react-core-app.csproj"
RUN dotnet build "react-core-app.csproj" -c Release -o /app/build

# copy everything else and build app
COPY . .
RUN dotnet publish -c release -o /app --no-cache

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
FROM base AS final
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "react-core-app.dll"]
