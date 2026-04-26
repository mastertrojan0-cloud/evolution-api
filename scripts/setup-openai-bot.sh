#!/bin/bash
# =============================================================
#  ACM Digital — Setup automático do bot OpenAI
#  Executa uma vez após subir os containers e conectar o WA
# =============================================================

set -e

# ---- Configuração ----
API_URL="${API_URL:-http://localhost:8080}"
API_KEY="${API_KEY:-}"
INSTANCE_NAME="${INSTANCE_NAME:-}"
OPENAI_KEY="${OPENAI_KEY:-}"

# ---- Cores ----
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; exit 1; }

echo ""
echo "=============================================="
echo "  ACM Digital — Configuração do Bot OpenAI"
echo "=============================================="
echo ""

# ---- Coleta de dados interativa ----
if [ -z "$API_KEY" ]; then
  read -rp "API Key da Evolution API: " API_KEY
fi

if [ -z "$INSTANCE_NAME" ]; then
  read -rp "Nome da instância WhatsApp (ex: assistente): " INSTANCE_NAME
fi

if [ -z "$OPENAI_KEY" ]; then
  read -rp "Chave OpenAI (sk-proj-...): " OPENAI_KEY
fi

read -rp "Prompt do assistente [ENTER para usar padrão]: " SYSTEM_PROMPT
if [ -z "$SYSTEM_PROMPT" ]; then
  SYSTEM_PROMPT="Voce e um assistente virtual simpatico, prestativo e descontraido. Responda sempre em portugues brasileiro de forma clara e amigavel, como se fosse um amigo proximo. Use emojis com moderacao."
fi

# ---- Verificar API ----
info "Verificando conexão com a API..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${API_URL}/")
[ "$STATUS" = "200" ] || err "API não está acessível em ${API_URL}"
ok "API online"

# ---- Verificar instância ----
info "Verificando instância ${INSTANCE_NAME}..."
CONN=$(curl -s "${API_URL}/instance/connectionState/${INSTANCE_NAME}" \
  -H "apikey: ${API_KEY}" | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
[ "$CONN" = "open" ] || err "Instância '${INSTANCE_NAME}' não está conectada (estado: ${CONN:-não encontrada}). Conecte o WhatsApp primeiro."
ok "Instância conectada"

# ---- Criar credenciais OpenAI ----
info "Criando credenciais OpenAI..."
CREDS_RESP=$(curl -s -X POST "${API_URL}/openai/creds/${INSTANCE_NAME}" \
  -H "apikey: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"OpenAI Principal\", \"apiKey\": \"${OPENAI_KEY}\"}")

CREDS_ID=$(echo "$CREDS_RESP" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$CREDS_ID" ] || err "Falha ao criar credenciais: ${CREDS_RESP}"
ok "Credencial criada: ${CREDS_ID}"

# ---- Criar bot ----
info "Criando bot OpenAI..."
BOT_RESP=$(curl -s -X POST "${API_URL}/openai/create/${INSTANCE_NAME}" \
  -H "apikey: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"enabled\": true,
    \"openaiCredsId\": \"${CREDS_ID}\",
    \"botType\": \"chatCompletion\",
    \"model\": \"gpt-4o-mini\",
    \"systemMessages\": [\"${SYSTEM_PROMPT}\"],
    \"maxTokens\": 1000,
    \"triggerType\": \"all\",
    \"triggerOperator\": \"equals\",
    \"delayMessage\": 1500,
    \"debounceTime\": 2,
    \"listeningFromMe\": false,
    \"stopBotFromMe\": false,
    \"keepOpen\": false,
    \"keywordFinish\": \"tchau\"
  }")

BOT_ID=$(echo "$BOT_RESP" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$BOT_ID" ] || err "Falha ao criar bot: ${BOT_RESP}"
ok "Bot criado: ${BOT_ID}"

echo ""
echo "=============================================="
ok "Configuração concluída!"
echo ""
echo "  Instância : ${INSTANCE_NAME}"
echo "  Bot ID    : ${BOT_ID}"
echo "  Modelo    : gpt-4o-mini"
echo "  Trigger   : Responde a TODAS as mensagens"
echo "  Encerrar  : Digite 'tchau'"
echo ""
echo "  Teste enviando uma mensagem para o número"
echo "  conectado e aguarde a resposta do bot."
echo "=============================================="
echo ""
