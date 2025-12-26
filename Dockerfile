# Use a Node.js base image
FROM node:22-bullseye

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y jq curl wget

# --- Add OpenJDK 21 ---
ENV JAVA_HOME=/opt/jdk-21
ENV PATH="$JAVA_HOME/bin:$PATH"
RUN wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -O /tmp/openjdk.tar.gz && \
    mkdir -p "$JAVA_HOME" && \
    tar -xzf /tmp/openjdk.tar.gz -C "$JAVA_HOME" --strip-components=1 && \
    rm /tmp/openjdk.tar.gz
RUN java -version
# --------------------

# Install Firebase CLI
RUN npm install -g firebase-tools

# Install Vite
RUN npm install -g vite

# --- Add OpenAPI Generator CLI ---
# Download the OpenAPI Generator JAR file
ENV OPENAPI_GENERATOR_VERSION=7.0.1
RUN curl -L https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${OPENAPI_GENERATOR_VERSION}/openapi-generator-cli-${OPENAPI_GENERATOR_VERSION}.jar -o /usr/local/bin/openapi-generator-cli.jar

# Create a shell script to make the tool easy to run
RUN echo '#!/bin/sh' > /usr/local/bin/openapi-generator-cli && \
    echo 'java -jar /usr/local/bin/openapi-generator-cli.jar "$@"' >> /usr/local/bin/openapi-generator-cli && \
    chmod +x /usr/local/bin/openapi-generator-cli
# -----------------------------------

# --- Add Flutter SDK ---
# Download the Flutter SDK
ENV FLUTTER_VERSION=3.38.0
RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -o /tmp/flutter.tar.xz

# Extract the Flutter SDK
RUN tar -xf /tmp/flutter.tar.xz -C /usr/local/

# Add Flutter to the PATH
ENV PATH="$PATH:/usr/local/flutter/bin"
# ---------------------

# Copy the rest of the application code
COPY . .

# Expose the default Vite port
EXPOSE 5173

# Expose the default Firebase emulator ports
EXPOSE 4000 5000 5001 8080 8085 9000 9099 9199 4400 4500 9150

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"]
