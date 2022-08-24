#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY ["nagp-devops-us/nagp-devops-us.csproj", "nagp-devops-us/"]
RUN dotnet restore "nagp-devops-us/nagp-devops-us.csproj"
COPY . .
WORKDIR "/src/nagp-devops-us"
RUN dotnet build "nagp-devops-us.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "nagp-devops-us.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "nagp-devops-us.dll"]