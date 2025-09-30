FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["src/MyDotnetApp/MyDotnetApp.csproj", "src/MyDotnetApp/"]
RUN dotnet restore "src/MyDotnetApp/MyDotnetApp.csproj"
COPY . .
WORKDIR "/src/src/MyDotnetApp"
RUN dotnet build "MyDotnetApp.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "MyDotnetApp.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyDotnetApp.dll"]
