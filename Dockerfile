# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:21-jre-alpine AS run
COPY --from=build /app/target/demo-*.jar /run/demo.jar

ARG USER=devops
ENV HOME=/home/$USER
RUN apk upgrade --no-cache && \
    adduser --disabled-password $USER && \
    chown $USER:$USER /run/demo.jar && \
    apk add --no-cache curl

HEALTHCHECK --interval=30s --timeout=10s --retries=2 --start-period=20s \
  CMD curl -f http://localhost:8080/ || exit 1

USER $USER
EXPOSE 8080
CMD ["java", "-jar", "/run/demo.jar"]