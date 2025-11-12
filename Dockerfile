# Build stage
FROM python:3.11-slim AS builder

WORKDIR /app

# Copy only requirements first to leverage Docker cache
COPY requirements.txt .

# Install dependencies in a specific location
RUN pip3 install --no-cache-dir --prefix=/install -r requirements.txt

# Copy only necessary files
COPY mkdocs.yml .
COPY docs/ docs/

# Final stage
FROM python:3.11-slim

WORKDIR /app

# Copy only the installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy only necessary files from builder
COPY --from=builder /app/mkdocs.yml .
COPY --from=builder /app/docs/ docs/

EXPOSE 8000

# Add a non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000"]
