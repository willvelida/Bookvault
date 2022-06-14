#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Bookvault.Inventory.API.csproj", "Bookvault.Inventory.API/"]
RUN dotnet restore "Bookvault.Inventory.API/Bookvault.Inventory.API.csproj"
COPY . .
WORKDIR "/src/Bookvault.Inventory.API"
RUN dotnet build "Bookvault.Inventory.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Bookvault.Inventory.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Bookvault.Inventory.API.dll"]