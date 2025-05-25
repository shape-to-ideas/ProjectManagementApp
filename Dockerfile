# Stage 1: Install Dependencies
ARG NODE=node:20-alpine
FROM ${NODE} AS base

RUN apk add --no-cache libc6-compat

WORKDIR /app

#Install pnpm
RUN npm i -g pnpm

# Copy all files
COPY . .

# Install dependencies
RUN pnpm i

## Stage 2: Build

## Create build file
RUN pnpm build

# Stage 3: Production Runner
ENV NODE_ENV production
ENV PORT 3000
ENV NEXT_TELEMETRY_DISABLED 1

# Install PM2 globally
RUN npm install -g pm2

# Create a non-root user
RUN addgroup --system --gid 1001 nodegroup
RUN adduser --system --uid 1001 appuser

# Copy necessary files
#COPY /app/public ./public
#COPY /app/package.json ./package.json
#COPY --chown=appuser:nodegroup /app/.next/standalone ./
#COPY --chown=appuser:nodegroup /app/.next/static ./.next/static

USER appuser

# Expose the listening port
EXPOSE 3000

# Start the application using PM2
CMD ["pm2-runtime", "node", "--", ".next/standalone/server.js"]
