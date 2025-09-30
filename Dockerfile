# Base runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
# Build image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["src/MyDotnetApp/MyDotnetApp.csproj", "MyDotnetApp/"]
RUN dotnet restore "MyDotnetApp/MyDotnetApp.csproj"
COPY . .
WORKDIR "/src/MyDotnetApp"
RUN dotnet build "MyDotnetApp.csproj" -c $configuration -o /app/build

# Publish image
FROM build AS publish
ARG configuration=Release
RUN dotnet publish "MyDotnetApp.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyDotnetApp.dll"]
