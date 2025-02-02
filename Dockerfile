# --- Base
FROM node:8-alpine as base
WORKDIR /home/2fa-2-slack



# --- Dependencies
FROM base as dependencies
ENV NPM_CONFIG_LOGLEVEL warn

RUN apk add --no-cache --virtual .build-deps \
	g++ \
	gcc \
	make \
	python

COPY package.json package-lock.json /home/2fa-2-slack/

RUN cd /home/2fa-2-slack/ && npm install

RUN apk del .build-deps



# --- Tests
FROM base as tests
COPY --from=dependencies /home/2fa-2-slack/node_modules /home/2fa-2-slack/node_modules
COPY --chown=node:node . /home/2fa-2-slack

RUN npm run test && npm prune --production

RUN rm -rf \
	.babelrc \
	.dockerignore \
	.eslintignore \
	.eslintrc.json \
	npm-debug.log \
	npm-debug.log.* \
	*.tmp



# --- Release
FROM base AS release
COPY --from=tests --chown=node:node /home/2fa-2-slack /home/2fa-2-slack

ENV NODE_ENV=production
USER node
EXPOSE 8888
CMD ["npm", "run", "start"]