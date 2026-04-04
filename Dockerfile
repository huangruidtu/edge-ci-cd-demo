# ---------- Build stage ----------
FROM ubuntu:24.04 AS builder

RUN apt-get update && apt-get install -y \
    cmake \
    build-essential

WORKDIR /app

COPY . .

RUN cmake -S . -B build && cmake --build build

# ---------- Runtime stage ----------
FROM ubuntu:24.04

WORKDIR /app

COPY --from=builder /app/build/app .

CMD ["./app"]
