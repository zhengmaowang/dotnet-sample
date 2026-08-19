# ========================
# 1) Build stage
# ========================
# Pin your .NET 9 base image. Adjust tag based on official previews available.
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copy project file & restore
COPY dotnet-sample.csproj .
RUN dotnet restore dotnet-sample.csproj
RUN apt update -y
RUN apt-get install -y procps curl

# Copy remaining source code & publish (Release)
COPY . .
RUN dotnet publish -c Release -o out

# ========================
# 2) Runtime stage
# ========================
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
RUN apt update -y
RUN apt-get install -y procps curl

ENV ASPNETCORE_URLS=http://0.0.0.0:8080
# Copy the build output
COPY --from=build /app/out ./

# Expose a port
EXPOSE 8080

# Run the app
ENTRYPOINT ["dotnet", "dotnet-sample.dll"]
