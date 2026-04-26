#!/bin/bash
# Gera uma API Key aleatória segura para usar no .env
echo "API Key gerada:"
openssl rand -hex 16 | tr '[:lower:]' '[:upper:]'
