# = Corpora Docker =

# ==================================================== #
# == Build client ==
# ==================================================== #
FROM node:16.13.0-slim AS build-client
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y python2.7 git-core ca-certificates wget file fftw-dev sudo && \
    update-ca-certificates

# Install client dependencies
WORKDIR /src/l-atelier-des-chercheurs/corpora/public/
COPY public/package*.json ./
RUN npm install -g npm
RUN npm install --unsafe-perm=true
COPY public /src/l-atelier-des-chercheurs/corpora/public
RUN npm run build --unsafe-perm=true

# ==================================================== #
# == Server ==
# ==================================================== #
FROM node:16.13.0-slim
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y make gcc g++ python3 git-core ca-certificates wget file fftw-dev sudo curl libx11-xcb1 libxcomposite1 libxi6 libxext6 libxtst6 libnss3 libcups2 libxss1 libxrandr2 libasound2 libpangocairo-1.0-0 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 libdrm2 libdrm-dev libgbm1 libgbm-dev libice6 libsm6 && \
    update-ca-certificates

# Setup proper time for timezone
RUN apt-get install tzdata -y
ENV TZ="Europe/Paris"

# Install server dependencies
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV
WORKDIR /src/l-atelier-des-chercheurs/corpora
COPY package*.json ./
RUN npm install -g npm
RUN npm install --unsafe-perm=true && npm cache clean --force
COPY . .

# Cleanup heavy dependencies
RUN apt-get remove -y make gcc g++ python3 git-core && \
    apt-get autoremove -y

# Import builded client
COPY --from=build-client /src/l-atelier-des-chercheurs/corpora/public/dist/ /src/l-atelier-des-chercheurs/corpora/public/dist/

# Setup configuration
COPY settings.example.json settings.json

# Setup running user with rights on proper folders
RUN mkdir -p /home/node/Documents/corpora \
    && chown -R node:node /home/node /src/l-atelier-des-chercheurs \
    && chmod -R g+rw /home/node /src/l-atelier-des-chercheurs
USER node

VOLUME ["/home/node/Documents/corpora"]

EXPOSE 8080

HEALTHCHECK --interval=5s \
            --timeout=5s \
            --retries=6 \
            CMD curl -fs http://localhost:8080/ || exit 1

CMD ["node", "--inspect", "."]
