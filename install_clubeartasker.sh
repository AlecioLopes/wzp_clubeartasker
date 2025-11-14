#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

step() {
    echo -e "${PURPLE}[ETAPA]${NC} $1"
}

# Iniciar instalação
step "🚀 INICIANDO INSTALAÇÃO DO WUZAPI NO TERMUX"

# 1. Atualizar pacotes
step "1. Atualizando pacotes do Termux..."
pkg update && pkg upgrade
if [ $? -eq 0 ]; then
    log "Pacotes atualizados com sucesso"
else
    error "Falha ao atualizar pacotes"
    exit 1
fi

# 2. Instalar dependências
step "2. Instalando golang e git..."
pkg install golang git -y
if [ $? -eq 0 ]; then
    log "Golang e Git instalados com sucesso"
else
    error "Falha ao instalar dependências"
    exit 1
fi

# 3. Configurar storage
step "3. Configurando storage..."
termux-setup-storage
if [ $? -eq 0 ]; then
    log "Storage configurado com sucesso"
else
    warning "Configure o storage manualmente se necessário"
fi

# 4. Configurar Go modules
step "4. Configurando Go modules..."
export GO111MODULE=on
log "GO111MODULE=on"

# 5. Clonar repositório
step "5. Clonando repositório wuzapi..."
git clone https://github.com/asternic/wuzapi.git
if [ $? -eq 0 ]; then
    log "Repositório clonado com sucesso"
else
    error "Falha ao clonar repositório"
    exit 1
fi

# 6. Entrar no diretório
step "6. Acessando diretório wuzapi..."
cd wuzapi
if [ $? -eq 0 ]; then
    log "Diretório acessado com sucesso"
else
    error "Falha ao acessar diretório"
    exit 1
fi

# 7. Obter dependência whatsmeow
step "7. Obtendo dependência whatsmeow..."
go get -u go.mau.fi/whatsmeow@latest
if [ $? -eq 0 ]; then
    log "Whatsmeow obtido com sucesso"
else
    warning "Possível aviso na obtenção do whatsmeow"
fi

# 8. Limpar e organizar dependências
step "8. Organizando dependências..."
go mod tidy
if [ $? -eq 0 ]; then
    log "Dependências organizadas com sucesso"
else
    warning "Possíveis avisos no mod tidy"
fi

# 9. Compilar projeto
step "9. Compilando wuzapi..."
go build .
if [ $? -eq 0 ]; then
    log "Compilação realizada com sucesso"
else
    error "Falha na compilação"
    exit 1
fi

# 10. Criar arquivo .env
step "10. Criando arquivo de configuração .env..."
cat > .env << EOF
WUZAPI_ADMIN_TOKEN=clubeartsker
WUZAPI_GLOBAL_ENCRYPTION_KEY=clubeartasker_wuzapi_master_code
WUZAPI_GLOBAL_HMAC_KEY=clubeartasker_wuzapi_master_code
TZ=America/Sao_Paulo
WEBHOOK_FORMAT=json
SESSION_DEVICE_NAME=Clube AR-WA/Tasker
WUZAPI_PORT=8080
MEDIA_DIR=/storage/emulated/0/WuzAPI/media
SQLITE_BUSY_TIMEOUT=10000
SQLITE_JOURNAL_MODE=WAL
SQLITE_SYNCHRONOUS=NORMAL
SQLITE_CACHE_SIZE=2000
EOF

if [ $? -eq 0 ]; then
    log "Arquivo .env criado com sucesso"
else
    error "Falha ao criar arquivo .env"
    exit 1
fi

# 11. Criar diretório de mídia
step "11. Criando diretório de mídia..."
mkdir -p /storage/emulated/0/WuzAPI/media
if [ $? -eq 0 ]; then
    log "Diretório de mídia criado com sucesso"
else
    warning "Não foi possível criar diretório de mídia"
fi

# 12. Executar em segundo plano com cores
step "12. Iniciando wuzapi em segundo plano..."
info "O WuzAPI será executado em background com logging colorido"
info "Para ver os logs: tail -f wuzapi.log"
info "Para parar o serviço: pkill wuzapi"

# Executar em background com logging colorido
./wuzapi -logtype=console -color=true > wuzapi.log 2>&1 &

# Verificar se está rodando
sleep 3
if pgrep -x "wuzapi" > /dev/null; then
    log "✅ WuzAPI iniciado com sucesso em segundo plano!"
    info "📱 Acesse: http://localhost:8080"
    info "📋 Token Admin: clubeartsker"
    info "📁 Logs salvos em: wuzapi.log"
    info "🔍 Ver logs em tempo real: tail -f wuzapi.log"
else
    error "❌ Falha ao iniciar WuzAPI"
    info "📋 Verifique o log: cat wuzapi.log"
fi

step "🎉 INSTALAÇÃO CONCLUÍDA!"
info "Não feche o Termux para manter o bot rodando"
info "Use 'pkill wuzapi' para parar o serviço"
