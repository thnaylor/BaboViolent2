FROM node:20-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev
COPY index.js ./
VOLUME /app/data
ENV STATE_FILE=/app/data/state.json
CMD ["node", "index.js"]
