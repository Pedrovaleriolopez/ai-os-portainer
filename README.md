# AI-OS Portainer Deployment

Sistema unificado de orquestração com MCPs integrados para a Allfluence.

## 🏗️ Arquitetura

### Serviços Principais
- **ai-os-api** (2 réplicas): API REST principal na porta 8000
- **ai-os-worker** (2 réplicas): Processador de jobs em background
- **ai-os-scheduler** (1 réplica): Agendador de tarefas cron

### Integrações
- **Redis**: Cache e fila de mensagens (serviço existente)
- **PostgreSQL**: Banco de dados principal (serviço existente)
- **Neo4j**: Banco de dados de grafos para memory system (serviço existente)
- **Traefik**: Proxy reverso com SSL automático (serviço existente)

## 🚀 Deploy via Portainer

### 1. Pré-requisitos
- Docker Swarm configurado
- Serviços base rodando: redis_redis, postgres_postgres, neo4j_neo4j, traefik_traefik
- Network overlay: network_public

### 2. Configuração no Portainer
1. Acessar Portainer
2. Stacks → Add Stack → Repository
3. URL: `https://github.com/Pedrovaleriolopez/ai-os-portainer.git`
4. Branch: `main`
5. GitOps: Polling (5 minutos)

### 3. Variáveis de Ambiente
```env
# Bancos de Dados (usar senhas existentes)
REDIS_PASSWORD=
NEO4J_PASSWORD=
POSTGRES_PASSWORD=

# Segurança (gerar novas)
JWT_SECRET=
ORCHESTRATOR_API_KEY=
UNIVERSAL_MEMORY_API_KEY=
CLAUDE_CODE_API_KEY=
```

## 🔗 Endpoints

- **API**: https://ai-os.allfluence.ai
- **Health Check**: https://ai-os.allfluence.ai/health
- **Metrics**: https://ai-os.allfluence.ai/metrics

## 📊 Monitoramento

```bash
# Status dos serviços
docker service ls | grep ai-os

# Logs em tempo real
docker service logs -f ai-os_ai-os-api

# Métricas de recursos
docker stats $(docker ps -q --filter label=com.docker.stack.namespace=ai-os)
```

## 🛠️ Manutenção

### Atualizar configuração
1. Fazer commit das mudanças neste repositório
2. Aguardar 5 minutos para GitOps ou forçar update no Portainer

### Escalar serviços
```bash
docker service scale ai-os_ai-os-api=3
docker service scale ai-os_ai-os-worker=4
```

### Backup do banco
```bash
# PostgreSQL
docker exec postgres_postgres.1.$(docker service ps postgres_postgres -q) \
  pg_dump -U postgres ai_os > ai_os_backup.sql

# Neo4j
docker exec neo4j_neo4j.1.$(docker service ps neo4j_neo4j -q) \
  neo4j-admin dump --database=neo4j --to=/backup/neo4j.dump
```

## 🐛 Troubleshooting

### Serviço não inicia
```bash
docker service ps ai-os_ai-os-api --no-trunc
docker service inspect ai-os_ai-os-api
```

### Problemas de conectividade
```bash
# Testar Redis
docker exec $(docker ps -qf "name=ai-os_ai-os-api") redis-cli -h redis_redis ping

# Testar PostgreSQL
docker exec $(docker ps -qf "name=ai-os_ai-os-api") pg_isready -h postgres_postgres

# Testar Neo4j
docker exec $(docker ps -qf "name=ai-os_ai-os-api") curl -f http://neo4j_neo4j:7474
```

### Logs de erro
```bash
docker service logs ai-os_ai-os-api --tail 100 --follow
```

## 📦 Estrutura do Projeto

```
ai-os/
├── packages/
│   ├── api/            # API REST
│   ├── worker/         # Background jobs
│   ├── scheduler/      # Cron jobs
│   └── shared/         # Código compartilhado
├── mcps/
│   ├── universal-memory/
│   ├── claude-code/
│   └── orchestrator/
└── docker-compose.yml
```

## 🔐 Segurança

- Todas as comunicações internas via network_public (encrypted overlay)
- SSL/TLS automático via Let's Encrypt (Traefik)
- Autenticação JWT para API
- Secrets gerenciados via environment variables

## 📈 Performance

- Auto-scaling baseado em CPU/Memory
- Load balancing entre réplicas
- Cache Redis para reduzir carga no banco
- Workers assíncronos para tarefas pesadas

---

**Allfluence** - Transformando criatividade em resultados mensuráveis