# ---------- build stage ----------
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /build

# Копируем POM и все модули
COPY pom.xml .
COPY common    common
COPY api       api
COPY streaming streaming
COPY infra     infra
COPY tools     tools

# Сборка модуля api и его зависимостей
RUN mvn -B -pl api -am clean package -DskipTests

# ---------- runtime stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# Копируем готовый fat‑jar
COPY --from=builder /build/api/target/api-0.0.1-SNAPSHOT.jar app.jar

# Открываем порт, запускаем приложение
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
