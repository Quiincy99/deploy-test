FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5168

ENV ASPNETCORE_URLS=http://+:5168

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["deploy-test.csproj", "./"]
RUN dotnet restore "deploy-test.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "deploy-test.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "deploy-test.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "deploy-test.dll"]
