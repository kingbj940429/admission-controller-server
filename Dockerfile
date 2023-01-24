FROM node:12.18.2
RUN mkdir /var/node
COPY ./ /var/node
WORKDIR /var/node
RUN npm i
RUN npm i -g pm2
CMD [ "npm", "run", "prod" ]