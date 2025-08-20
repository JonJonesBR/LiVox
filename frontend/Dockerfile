# Stage 1: Build the Next.js application
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json from the frontend directory
COPY frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code from the frontend directory
COPY frontend/. .

# Build the Next.js application
RUN npm run build
RUN ls -laR /app/.next/static

# Stage 2: Run the Next.js application
FROM node:20-alpine

WORKDIR /app

# Copy package.json and package-lock.json
COPY frontend/package*.json ./

# Copy built Next.js application and dependencies
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY frontend/public ./public
COPY frontend/src ./src

EXPOSE 3000

# Run the Next.js application in production mode
CMD ["npm", "start"]
