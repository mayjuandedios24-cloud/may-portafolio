FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw && ./mvnw dependency:go-offline -DskipTests

COPY src ./src
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=build /app/target/classes ./classes
COPY --from=build /app/src/main/webapp ./src/main/webapp
COPY --from=build /app/target/dependency ./dependency

EXPOSE 8080
CMD ["sh", "-c", "java -cp classes:dependency/* com.example.demo.Main"]
