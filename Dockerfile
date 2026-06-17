# ----------------------
# STEP 1: Build Astro app
# ----------------------
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency files (lebih aman tanpa wildcard)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy semua source code
COPY . .

# Build project untuk SSR
RUN npm run build


# ----------------------
# STEP 2: Run with Node.js
# ----------------------
FROM node:22-alpine AS runner

WORKDIR /app

# Copy only production deps
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy hasil build dari builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/.astro ./.astro
COPY --from=builder /app/node_modules ./node_modules

# Expose port (default Astro SSR: 3000)
EXPOSE 3000

# Jalankan SSR server
CMD ["node", "./dist/server/entry.mjs"]
