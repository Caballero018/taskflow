# syntax=docker/dockerfile:1
#
# Imagen de TaskFlow (Flutter Web) construida en dos etapas (multi-stage),
# siguiendo el mismo patrón del Dockerfile de my-vaccine-api:
#   1. "build": una imagen con el SDK compila la aplicación.
#   2. "final": una imagen liviana solo con lo necesario para ejecutarla.
# El SDK de Flutter (más de 1 GB) se queda en la primera etapa y NO llega a
# la imagen final (unos 150 MB: Nginx + la app compilada con CanvasKit).

# Misma versión de Flutter que el entorno de desarrollo (flutter --version).
ARG FLUTTER_VERSION=3.47.4

# ---------- Etapa 1: compilación ----------
FROM debian:bookworm-slim AS build
ARG FLUTTER_VERSION

# Herramientas que necesita el SDK de Flutter para instalarse.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# SDK de Flutter descargado desde la etiqueta oficial de la versión elegida.
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
      https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics --enable-web \
    && flutter precache --web

WORKDIR /app

# Primero solo los archivos de dependencias: si no cambian, Docker reutiliza
# esta capa en caché (igual que el `dotnet restore` del proyecto del profesor).
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Luego el código fuente y la compilación web en modo release.
COPY . .
RUN flutter build web --release

# ---------- Etapa 2: servidor web ----------
FROM nginx:1.29-alpine AS final

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
# El comando por defecto de la imagen de Nginx ya lo inicia en primer plano.
