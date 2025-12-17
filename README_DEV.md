# Guia de Desenvolvimento - Onboarding

## 1. Setup do Projeto

### 1.1 Clonar o repositório

Você pode clonar o repositório usando **SSH** ou **HTTPS**:

- **SSH:**
   ```bash
   git clone git@github.com:SEU_USUARIO/SEU_REPOSITORIO.git
   ```
- **HTTPS:**
   ```bash
   git clone https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
   ```

> **Dica:** Para usar SSH, você precisa ter uma chave SSH cadastrada no GitHub/GitLab. Veja a documentação oficial para gerar e adicionar sua chave SSH.

Depois de clonar, acesse a pasta do projeto:

- **Windows:**
   ```bat
   cd caminho\para\a\pasta\do\projeto
   ```
- **Linux/Mac:**
   ```sh
   cd caminho/para/a/pasta/do/projeto
   ```

### 1.2 Copiar o arquivo de variáveis de ambiente

- **Windows (Prompt de Comando):**
   ```bat
   copy .env.example .env
   ```
- **Linux/Mac:**
   ```sh
   cp .env.example .env
   ```
Edite o arquivo `.env` conforme necessário.

### 1.3 Subir os containers Docker

No terminal (Windows, Linux ou Mac):
```sh
docker-compose up -d
```

## 2. Healthchecks

Os serviços possuem healthchecks configurados no docker-compose. Para verificar o status:
```sh
docker ps
# Veja a coluna STATUS (healthy/unhealthy)
```

## 3. Models e Migrations

### Criar/Editar Models
Edite ou crie suas models em `app/models.py` usando SQLAlchemy.

### Gerar uma migration automaticamente
```sh
docker exec -it bemagro_api /bin/bash
alembic revision --autogenerate -m "descrição da alteração"
# Exemplo: alembic revision --autogenerate -m "create user table"
```
**Sempre revise o arquivo gerado em migrations/versions antes de aplicar!**

### Aplicar migrations
```sh
alembic upgrade head
```

### Rollback (desfazer última migration)
```sh
alembic downgrade -1
```

## 4. Banco de Dados e Extensões PostGIS

### Como verificar se o PostGIS está ativo
1. Entre no container do banco:
   ```sh
   docker exec -it bemagro_postgis psql -U postgres -d postgres
   ```
2. Veja a versão do PostGIS:
   ```sql
   SELECT postgis_version();
   ```
3. Liste todas as extensões instaladas:
   ```sql
   \dx
   ```

### Conferir tabelas do projeto
```sql
\dt public.*
```
Você deve ver as tabelas criadas pelas suas migrations (ex: users, locations, places).

## 5. Dicas rápidas

- Sempre revise as migrations antes de aplicar, para não remover tabelas do sistema ou extensões.
- Use apenas os comandos de `create_table` para suas tabelas de negócio.
- Para criar novas migrations após alterar models:
  ```sh
  alembic revision --autogenerate -m "descrição"
  alembic upgrade head
  ```
- Para desfazer a última migration:
  ```sh
  alembic downgrade -1
  ```

  ## 6. Celery Worker: Enfileiramento e Processamento de Tasks

### Garantindo que o Worker Celery está rodando

O serviço do worker já está configurado no `docker-compose.yml` e sobe automaticamente junto com os containers.

Para subir todos os serviços (incluindo o worker Celery):
```sh
docker-compose up -d
```

### Disparando uma task de exemplo

A API possui um endpoint de teste que enfileira uma task Celery no Redis.

Exemplo de chamada usando `curl` (Linux/Git Bash) ou navegador:
```sh
curl "http://localhost:8000/sum?a=2&b=3"
```
**No Windows PowerShell, use:**
```powershell
Invoke-WebRequest -Uri "http://localhost:8000/sum?a=2&b=3"
```
A resposta será algo como:
```json
{"task_id":"<id-da-task>"}
```

### Verificando o processamento da task

Para checar se a task foi processada com sucesso, veja os logs do worker:
```sh
docker logs bemagro_worker
```
Você deve ver uma linha parecida com:
```
Task app.worker.add[<id-da-task>] succeeded in ...: 5
```

- O worker Celery deve estar rodando como serviço no Docker Compose.
- O endpoint `/sum` deve enfileirar uma task e retornar um `task_id`.
- Os logs do worker devem mostrar que a task foi processada com sucesso.
- (Opcional) Você pode monitorar o status das tasks usando o serviço Flower (caso esteja habilitado em `docker-compose.yml`) acessando:
   - http://localhost:5555

---

---