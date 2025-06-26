#!/bin/bash
# Comandos SSH para verificar e preparar o ambiente AI-OS

echo "🔍 Verificando ambiente para AI-OS..."
echo "===================================="

# 1. Verificar se as portas necessárias estão livres
echo -e "\n1. Verificando portas..."
netstat -tulpn | grep -E "8000|8001|8002" && echo "⚠️ Portas 8000-8002 em uso!" || echo "✅ Portas 8000-8002 livres"

# 2. Testar conexão com Redis
echo -e "\n2. Testando Redis..."
REDIS_CONTAINER=$(docker ps --filter "name=redis_redis" --format "{{.Names}}" | head -1)
if [ -n "$REDIS_CONTAINER" ]; then
    docker exec $REDIS_CONTAINER redis-cli ping && echo "✅ Redis OK" || echo "❌ Redis falhou"
else
    echo "❌ Container Redis não encontrado"
fi

# 3. Testar conexão com PostgreSQL
echo -e "\n3. Testando PostgreSQL..."
POSTGRES_CONTAINER=$(docker ps --filter "name=postgres_postgres" --format "{{.Names}}" | head -1)
if [ -n "$POSTGRES_CONTAINER" ]; then
    docker exec $POSTGRES_CONTAINER psql -U postgres -c "SELECT version();" && echo "✅ PostgreSQL OK" || echo "❌ PostgreSQL falhou"
else
    echo "❌ Container PostgreSQL não encontrado"
fi

# 4. Verificar Neo4j
echo -e "\n4. Verificando Neo4j..."
NEO4J_CONTAINER=$(docker ps --filter "name=neo4j_neo4j" --format "{{.Names}}" | head -1)
if [ -n "$NEO4J_CONTAINER" ]; then
    echo "✅ Neo4j container encontrado: $NEO4J_CONTAINER"
    echo "⚠️ Para testar Neo4j, use: docker exec $NEO4J_CONTAINER cypher-shell -u neo4j -p <senha>"
else
    echo "❌ Container Neo4j não encontrado"
fi

# 5. Verificar Traefik
echo -e "\n5. Verificando Traefik..."
TRAEFIK_CONTAINER=$(docker ps --filter "name=traefik_traefik" --format "{{.Names}}" | head -1)
if [ -n "$TRAEFIK_CONTAINER" ]; then
    echo "✅ Traefik encontrado: $TRAEFIK_CONTAINER"
    # Verificar configuração
    docker exec $TRAEFIK_CONTAINER traefik version 2>/dev/null && echo "✅ Traefik respondendo"
else
    echo "❌ Container Traefik não encontrado"
fi

# 6. Verificar domínio
echo -e "\n6. Verificando DNS para ai-os.allfluence.ai..."
nslookup ai-os.allfluence.ai || echo "⚠️ Domínio ainda não configurado"

# 7. Listar todos os serviços do Swarm
echo -e "\n7. Serviços ativos no Swarm:"
docker service ls

# 8. Verificar certificados SSL existentes
echo -e "\n8. Verificando certificados SSL..."
docker exec $TRAEFIK_CONTAINER ls -la /letsencrypt/acme.json 2>/dev/null && echo "✅ Certificados Let's Encrypt encontrados" || echo "⚠️ Certificados não encontrados"

echo -e "\n✅ Verificação completa!"