# 🤖 Assistente Pessoal WhatsApp — ACM Digital

Sistema de assistente virtual inteligente para WhatsApp, baseado na **Evolution API v2.3.7** com integração **OpenAI GPT-4o-mini**. Responde automaticamente mensagens no WhatsApp usando Inteligência Artificial, com tom amigável e conversacional em português brasileiro.

---

## ✨ Funcionalidades

- Resposta automática a mensagens do WhatsApp via IA (OpenAI GPT)
- Suporte a texto, áudio (transcrição) e imagens
- Sessões de conversa com contexto por contato
- Painel de gerenciamento via browser (`/manager`)
- Documentação interativa da API (`/docs`)
- Banco de dados PostgreSQL com histórico de mensagens
- Cache Redis para performance
- Reconexão automática ao WhatsApp
- Configuração por variáveis de ambiente

---

## 🧰 Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Docker | 24+ |
| Docker Compose | v2+ |
| Chave de API OpenAI | Com créditos ativos |
| Número de WhatsApp | Para escanear o QR Code |

---

## 🚀 Instalação rápida (novo cliente)

### 1. Clone ou extraia o projeto

```bash
# Via git
git clone https://github.com/SEU_USUARIO/assistente-pessoal-whatsapp.git
cd assistente-pessoal-whatsapp

# Ou extraia o ZIP enviado pelo suporte ACM Digital
unzip assistente-pessoal-whatsapp.zip
cd assistente-pessoal-whatsapp
```

### 2. Configure o ambiente

```bash
cp .env.example .env
```

Abra o `.env` e preencha os campos obrigatórios:

```env
# Nome da instalação (sem espaços, ex: joao-silva)
SERVER_NAME=nome-do-cliente

# Chave de autenticação da API — gere uma aleatória forte
AUTHENTICATION_API_KEY=CHAVE_ALEATORIA_FORTE

# Banco de dados
POSTGRES_DATABASE=nome_do_banco
POSTGRES_USERNAME=usuario_db
POSTGRES_PASSWORD=senha_forte_db
DATABASE_CONNECTION_URI=postgresql://usuario_db:senha_forte_db@postgres:5432/nome_do_banco?schema=api
DATABASE_CONNECTION_CLIENT_NAME=nome_cliente_exchange

# OpenAI (obter em platform.openai.com/api-keys)
OPENAI_API_KEY_GLOBAL=sk-proj-SUACHAVE...
```

### 3. Suba os containers

```bash
docker compose up -d
```

### 4. Verifique se está rodando

```bash
docker compose ps
# Todos devem estar "healthy" ou "running"

curl http://localhost:8080/
# Retorna: {"status":200,"message":"Bem-vindo..."}
```

### 5. Conecte o WhatsApp

1. Acesse: `http://localhost:8080/manager`
2. Clique em **"Nova Instância"** → dê um nome (ex: `assistente`)
3. Escaneie o **QR Code** com o WhatsApp do cliente
4. Aguarde aparecer **CONNECTED**

### 6. Configure o bot OpenAI (execute uma vez)

```bash
bash scripts/setup-openai-bot.sh
```

O script vai pedir o nome da instância e configurar o bot automaticamente.

---

## ⚙️ Variáveis de ambiente importantes

| Variável | Descrição | Padrão |
|---|---|---|
| `SERVER_NAME` | Nome do servidor | `evolution` |
| `SERVER_PORT` | Porta da API | `8080` |
| `AUTHENTICATION_API_KEY` | Chave de acesso à API | — |
| `OPENAI_ENABLED` | Habilitar OpenAI | `true` |
| `OPENAI_API_KEY_GLOBAL` | Chave OpenAI | — |
| `DATABASE_PROVIDER` | Banco de dados | `postgresql` |
| `CACHE_REDIS_ENABLED` | Usar Redis | `true` |
| `DEL_INSTANCE` | Auto-deletar instâncias inativas | `false` |

---

## 🔄 Operações comuns

```bash
# Reiniciar após mudar o .env (SEMPRE use up -d, nunca restart)
docker compose up -d

# Ver logs em tempo real
docker compose logs -f api

# Parar tudo
docker compose down

# Backup do banco
docker exec acm_digital_postgres pg_dump -U POSTGRES_USER POSTGRES_DB > backup_$(date +%Y%m%d).sql

# Atualizar versão
docker compose down && docker compose build --no-cache && docker compose up -d
```

---

## 🛠️ Solução de problemas

| Problema | Causa | Solução |
|---|---|---|
| Bot não responde | `OPENAI_ENABLED=false` | Verificar `.env` e rodar `docker compose up -d` |
| Erro 429 OpenAI | Cota esgotada | Adicionar créditos em platform.openai.com/account/billing |
| WhatsApp desconectado | Sessão expirada | Acessar `/manager` e escanear QR Code novamente |
| Mudança no `.env` não aplica | Container não recriado | Usar `docker compose up -d` (não `docker restart`) |
| Porta 8080 ocupada | Conflito de porta | Alterar `SERVER_PORT` no `.env` e portas no `docker-compose.yaml` |

---

## 🏗️ Estrutura do projeto

```
.
├── src/                    # Código-fonte TypeScript
│   └── api/integrations/
│       ├── chatbot/        # OpenAI, Typebot, N8N, etc.
│       ├── channel/        # Baileys (WhatsApp Web), Meta API
│       └── event/          # Webhook, WebSocket, RabbitMQ
├── prisma/                 # Schema e migrações PostgreSQL
├── Docker/                 # Scripts de inicialização
├── manager/                # Painel web
├── scripts/                # Scripts de configuração
├── docker-compose.yaml     # Orquestração de containers
├── Dockerfile              # Build da imagem
├── .env.example            # Template de configuração
└── README.md               # Este arquivo
```

---

## 🔐 Segurança em produção

- Nunca commite o arquivo `.env` no Git
- Use senhas fortes para banco e API key
- Coloque Nginx/Traefik com HTTPS na frente
- Restrinja porta 8080 via firewall

---

## 📞 Suporte ACM Digital

- 📧 contato@acmdigital.com.br

---

## 📄 Licença

Baseado na [Evolution API](https://github.com/EvolutionAPI/evolution-api) — Apache 2.0.  
Customizações © ACM Digital.
