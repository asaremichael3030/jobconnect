# --- Stage 1: Build ---
FROM node:20-alpine AS builder

# Install build tools for native modules (like bcrypt)
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install ALL dependencies (explicitly including devDependencies like typescript)
RUN npm install --include=dev --no-audit --no-fund

# Copy the rest of the source code
COPY . .

# Compile TypeScript to JavaScript
RUN npm run build

# --- Stage 2: Production ---
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install ONLY production dependencies (skips typescript, jest, etc.)
RUN npm install --omit=dev --no-audit --no-fund

# Copy the compiled JavaScript and needed files from the builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src/db/schema.sql ./src/db/schema.sql
COPY --from=builder /app/src ./src


# Create the uploads directory
RUN mkdir -p uploads

EXPOSE 5000

# Start the app
CMD ["npm", "start"]