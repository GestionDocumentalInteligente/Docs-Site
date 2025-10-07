# Dockerfile para Railway - MkDocs Material
FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Copiar requirements y instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar toda la configuración y documentación
COPY . .

# Construir el sitio estático
RUN mkdocs build

# Instalar servidor web ligero
RUN pip install --no-cache-dir mkdocs-material[imaging]

# Exponer puerto (Railway usa la variable PORT)
ENV PORT=8080
EXPOSE 8080

# Servir el sitio usando el servidor integrado de MkDocs
CMD mkdocs serve --dev-addr=0.0.0.0:$PORT
