Here are the contents of each Dockerfile shown in the images along with definitions for each part.

### 1. `kitap-server` Dockerfile

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /kairos/server
EXPOSE 8080
LABEL org.opencontainers.image.source="https://github.com/kairostechnologiesinc/kitap-server"
RUN apt update && apt -y install curl
ADD ./target/kitap-server-*.jar .
ADD ./kairos-ssl.p12 .
CMD ["java", "-jar", "kitap-server-0.0.1-SNAPSHOT.jar"]
```

**Definitions:**

- `FROM openjdk:17-jdk-slim`: Specifies the base image, which is a slim version of OpenJDK 17 JDK.
- `WORKDIR /kairos/server`: Sets the working directory inside the container to `/kairos/server`.
- `EXPOSE 8080`: Exposes port 8080 to allow external access to the application.
- `LABEL org.opencontainers.image.source="https://github.com/kairostechnologiesinc/kitap-server"`: Adds metadata to the image with the source URL.
- `RUN apt update && apt -y install curl`: Updates the package lists and installs `curl`.
- `ADD ./target/kitap-server-*.jar .`: Adds the JAR file from the local `target` directory to the working directory.
- `ADD ./kairos-ssl.p12 .`: Adds the `kairos-ssl.p12` file to the working directory.
- `CMD ["java", "-jar", "kitap-server-0.0.1-SNAPSHOT.jar"]`: Specifies the command to run when the container starts.

### 2. `kitap-web` Dockerfile

```dockerfile
FROM node:18.14.2-alpine3.17 AS builds
WORKDIR /kairos/web
ADD package.json .
RUN npm install
ADD . .
RUN npm run build

FROM nginx:stable-alpine3.17-slim
WORKDIR /kairos/web
LABEL org.opencontainers.image.source="https://github.com/kairostechnologiesinc/kitap-web"
EXPOSE 80 443
COPY --from=builds /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY --from=builds /kairos/web/build/ ./build/
COPY /cert/nginx/cert/ /etc/nginx/cert/
CMD ["nginx", "-g", "daemon off;"]
```

**Definitions:**

- `FROM node:18.14.2-alpine3.17 AS builds`: Uses Node.js Alpine image as the build stage.
- `WORKDIR /kairos/web`: Sets the working directory to `/kairos/web`.
- `ADD package.json .`: Adds the `package.json` file to the working directory.
- `RUN npm install`: Installs the project dependencies.
- `ADD . .`: Adds all files from the local directory to the working directory.
- `RUN npm run build`: Builds the project.
- `FROM nginx:stable-alpine3.17-slim`: Uses Nginx Alpine image for the final stage.
- `WORKDIR /kairos/web`: Sets the working directory to `/kairos/web`.
- `LABEL org.opencontainers.image.source="https://github.com/kairostechnologiesinc/kitap-web"`: Adds metadata to the image with the source URL.
- `EXPOSE 80 443`: Exposes ports 80 and 443 for HTTP and HTTPS.
- `COPY --from=builds /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf`: Copies the Nginx configuration from the build stage.
- `COPY --from=builds /kairos/web/build/ ./build/`: Copies the built project from the build stage.
- `COPY /cert/nginx/cert/ /etc/nginx/cert/`: Copies the SSL certificates to the Nginx directory.
- `CMD ["nginx", "-g", "daemon off;"]`: Runs Nginx in the foreground.

### 3. `kitap-lowcode` Dockerfile

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /kairos/lowcode
EXPOSE 8081
LABEL org.opencontainers.image.source="https://github.com/kairostechnologiesinc/kitap-lowcode"
COPY xpaths.json .
#RUN apt-get install -y wget firefox-esr
#RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
#    apt-get -y install ./google-chrome-stable_current_amd64.deb
ADD ./target/low-code-framework.jar .
CMD ["java", "-jar", "low-code-framework.jar"]
```

**Definitions:**

- `FROM openjdk:17-jdk-slim`: Specifies the base image, which is a slim version of OpenJDK 17 JDK.
- `WORKDIR /kairos/lowcode`: Sets the working directory inside the container to `/kairos/lowcode`.
- `EXPOSE 8081`: Exposes port 8081 to allow external access to the application.
- `LABEL org.opencontainers.image.source="https://github.com/kairostechnologiesinc/kitap-lowcode"`: Adds metadata to the image with the source URL.
- `COPY xpaths.json .`: Copies the `xpaths.json` file to the working directory.
- `#RUN apt-get install -y wget firefox-esr`: Commented out command to install `wget` and `firefox-esr`.
- `#RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \ apt-get -y install ./google-chrome-stable_current_amd64.deb`: Commented out command to download and install Google Chrome.
- `ADD ./target/low-code-framework.jar .`: Adds the JAR file from the local `target` directory to the working directory.
- `CMD ["java", "-jar", "low-code-framework.jar"]`: Specifies the command to run when the container starts.