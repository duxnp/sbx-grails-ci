# Build stage: compile source and produce ROOT.war
FROM eclipse-temurin:17 AS build
LABEL maintainer="Me"

RUN apt-get update && apt-get install -y --no-install-recommends \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN dos2unix ./gradlew && chmod +x ./gradlew
RUN ./gradlew bootWar -Dgrails.env=prod --no-daemon

# Runtime stage: lean image containing only the pre-built WAR
FROM eclipse-temurin:17-jre

RUN apt-get update && apt-get install -y --no-install-recommends \
    dos2unix \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate a locale file
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

# Env variables for locale
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

WORKDIR /app
COPY --from=build /app/build/libs/ROOT.war .

ADD ./docker-entrypoint.sh /tmp
RUN chmod +x /tmp/docker-entrypoint.sh && \
    dos2unix /tmp/docker-entrypoint.sh

ENTRYPOINT ["/tmp/docker-entrypoint.sh"]
