FROM node:20-alpine

WORKDIR /srv/app

COPY package*.json ./
RUN npm install && npm install pg --save

COPY . .

# Increase memory limit for Node
ENV NODE_OPTIONS="--max-old-space-size=3072"

# Give permission to Strapi binary
RUN chmod +x node_modules/.bin/strapi

RUN npm run build

EXPOSE 1337

CMD ["npm", "run", "start"]