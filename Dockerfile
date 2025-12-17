FROM python:3.11-slim

# --- Dependências de sistema para geoprocessamento ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    curl \
    wget \
    git \
    libpq-dev \
    libgdal-dev \
    gdal-bin \
    libgeos-dev \
    libproj-dev \
    proj-bin \
    libspatialindex-dev \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# --- Variáveis necessárias para pacotes geoespaciais ---
ENV GDAL_VERSION=3.6.2
ENV GDAL_DATA=/usr/share/gdal
ENV PROJ_LIB=/usr/share/proj

# --- Diretório de trabalho ---
WORKDIR /app

# Copia requirements primeiro (cache layer)
COPY requirements.txt .

RUN pip install --upgrade pip setuptools wheel

RUN pip install -r requirements.txt

# Criação do usuário não-root
RUN useradd -m appuser
USER appuser

# Copia código
COPY . .

# Porta padrão da aplicação FastAPI
EXPOSE 8000

# Comando padrão (override no compose)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]