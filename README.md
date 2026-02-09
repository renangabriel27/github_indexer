# GitHub Indexer

[![CI Status](https://github.com/renangabriel27/github_indexer/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/renangabriel27/github_indexer/actions/workflows/ci.yml)
![Ruby](https://img.shields.io/badge/Ruby-4.0.1-red?logo=ruby)
![Rails](https://img.shields.io/badge/Rails-8.1.2-red?logo=rubyonrails)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Latest-blue?logo=postgresql)
![Redis](https://img.shields.io/badge/Redis-Latest-red?logo=redis)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-Latest-38B2AC?logo=tailwindcss)

Uma ferramenta para indexação e busca de perfis do GitHub.

## 📋 Sumário

- [✨ Funcionalidades](#-funcionalidades)
- [🛠️ Stack Tecnológica](#️-stack-tecnológica)
- [📦 Instalação](#-instalação)
- [⚙️ Configuração](#️-configuração)
- [📚 Documentação da API](#-documentação-da-api)
- [🧪 Testes](#-testes)
- [🏗️ Arquitetura](#️-arquitetura)
- [💡 Decisões Técnicas](#-decisões-técnicas)
- [⚖️ Trade-offs](#️-trade-offs)
- [⚠️ Limitações Conhecidas](#️-limitações-conhecidas)
- [🔧 Troubleshooting](#-troubleshooting)
- [🚀 Pontos de Melhoria](#-pontos-de-melhoria)
- [🤝 Contribuindo](#-contribuindo)
- [📄 Licença](#-licença)
- [👤 Autor](#-autor)

## 📸 Screenshots

### Lista de Perfis
![Lista de Perfis](public/screenshots/profile-list.png)

### Detalhes do Perfil
![Detalhes do Perfil](public/screenshots/profile-detail.png)

### Progresso de Scraping
![Progresso de Scraping](public/screenshots/profile-progress.png)

## ✨ Funcionalidades

- **Gerenciamento de Perfis**: Cadastre, indexe, busque e gerencie perfis do GitHub
- **Web Scraping**: Extração automática usando Chrome headless (Ferrum) com suporte a retry
- **Encurtamento de URLs**: Integração com Short.io para encurtamento de URLs
- **Processamento Assíncrono**: Jobs em background com Sidekiq + Redis
- **API RESTful**: Endpoints versionados com serialização otimizada
- **Rate Limiting**: Proteção contra abuso da API (100 req/min)
- **Interface Responsiva**: Interface moderna com TailwindCSS e ViewComponents

## 🛠️ Stack Tecnológica

**Backend**: Ruby 4.0.1, Rails 8.1.2, PostgreSQL, Redis, Sidekiq

**Frontend**: ViewComponent, TailwindCSS, Stimulus.js, Importmap

**Scraping & APIs**: Ferrum, Nokogiri, HTTParty

**API**: Blueprinter, Pagy, Rswag

**Qualidade**: RSpec, Capybara, FactoryBot, Rubocop, SimpleCov, Brakeman

## 📦 Instalação

### ⚡ Pré-requisitos

- Ruby 4.0.1 (via rbenv/asdf)
- PostgreSQL 14+
- Redis 6+
- Node.js 18+ (para TailwindCSS)
- Conta no [Short.io](https://short.io) (chave API gratuita)

### 🚀 Configuração

```bash
# Clone o repositório
git clone https://github.com/renangabriel27/github_indexer.git
cd github_indexer

# Instale as dependências Ruby
bundle install

# Configure as variáveis de ambiente
cp env.example .env
# Edite o arquivo .env e adicione suas credenciais

# Crie e configure o banco de dados
rails db:create db:migrate

# (Opcional) Popule com dados de exemplo
rails db:seed

# Inicie o Redis (em outro terminal)
redis-server

# Inicie o Sidekiq (em outro terminal)
bundle exec sidekiq

# Inicie o servidor de desenvolvimento
bin/dev

# Acesse em http://localhost:3000
```

### 🐳 Configuração com Docker

```bash
docker-compose up
docker-compose exec web rails db:migrate
# Acesse em http://localhost:3000
```

## ⚙️ Configuração

Crie um arquivo `.env` na raiz do projeto:

```env
DATABASE_URL=postgresql://postgres:password@localhost:5432/github_indexer_development
REDIS_URL=redis://localhost:6379/1
SHORTIO_API_KEY=your_api_key_here
SHORTIO_DOMAIN=go.short.io
RAILS_ENV=development
SECRET_KEY_BASE=generate_with_rails_secret
SIDEKIQ_USERNAME=admin
SIDEKIQ_PASSWORD=change_me_in_production
```

## 📚 Documentação da API

![Documentação da API](public/screenshots/api-docs.png)

Documentação interativa da API disponível em `/api-docs` (Swagger UI).

### 🔌 Endpoints

#### GET /api/v1/profiles

Lista paginada de perfis.

**Parâmetros de Query**: `page` (padrão: 1), `per_page` (padrão: 10, máximo: 100)

```bash
curl -X GET "http://localhost:3000/api/v1/profiles?page=1&per_page=10" \
  -H "Accept: application/json"
```

#### GET /api/v1/profiles/:id

Detalhes de um perfil.

```bash
curl -X GET "http://localhost:3000/api/v1/profiles/1" \
  -H "Accept: application/json"
```

### 🛡️ Rate Limiting

- **Limite**: 100 requisições por minuto por IP
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- **Excedido**: Retorna 429 Too Many Requests

## 🧪 Testes

```bash
# Suite completa de testes
bundle exec rspec

# Com relatório de cobertura
COVERAGE=true bundle exec rspec
open coverage/index.html

# Por tipo
bundle exec rspec spec/models spec/services    # Testes unitários
bundle exec rspec spec/requests                # Testes de integração
bundle exec rspec spec/features                # Testes de feature
```

### 🔍 Ferramentas de Qualidade

```bash
bundle exec rubocop        # Linting
bundle exec brakeman       # Análise de segurança
bundle exec bundle-audit   # Auditoria de dependências
```

## 🏗️ Arquitetura

```
app/
├── components/
│   ├── errors/              # Componentes de páginas de erro
│   ├── profiles/            # Componentes de perfil (Avatar, Card, Header, etc.)
│   ├── shared/              # Componentes compartilhados (Modal)
│   └── ui/                  # Componentes genéricos de UI (Button, Icon, Badge, etc.)
├── controllers/
│   ├── api/v1/              # Controllers da API
│   └── profiles_controller.rb
├── services/
│   ├── profiles/
│   │   ├── github/
│   │   │   ├── extractors/  # Extratores de dados (Avatar, Identity, Location, etc.)
│   │   │   ├── broadcaster.rb
│   │   │   ├── browser_manager.rb
│   │   │   ├── circuit_breaker.rb
│   │   │   ├── error_handler.rb
│   │   │   ├── html_parser.rb
│   │   │   ├── page_validator.rb
│   │   │   ├── scraper_service.rb
│   │   │   └── selectors.rb
│   │   ├── creator_service.rb
│   │   ├── rescan_service.rb
│   │   └── updater_service.rb
│   └── url_shortener/       # Adapter de encurtamento de URLs
├── jobs/                    # Jobs em background (Sidekiq)
├── queries/                 # Query Objects
├── serializers/             # Serializers da API (Blueprinter)
└── validators/              # Validadores customizados
```

### 🎯 Padrões de Projeto

- **Service Objects**: Encapsulam lógica de negócio complexa
- **Organizer Pattern**: Pipeline de execução sequencial de steps com `OrganizedService`, usado em `HtmlParser` para processar dados do scraping em etapas discretas com tratamento de falhas via Dry-Monads
- **Adapter Pattern**: Abstração de integração com serviços externos (encurtamento de URLs)
- **Query Objects**: Encapsulam queries complexas do ActiveRecord
- **Dry-Monads**: Tratamento funcional de erros com `Success` e `Failure`
- **Concerns**: Funcionalidade compartilhada entre models
- **ViewComponents**: Componentes frontend testáveis e reutilizáveis

### 📊 Fluxo de Dados

```mermaid
sequenceDiagram
    participant U as Usuario
    participant C as Controller
    participant S as CreatorService
    participant Q as Sidekiq
    participant J as ScraperJob
    participant G as GitHub
    participant AC as ActionCable

    U->>C: POST /profiles (name, username)
    C->>S: CreatorService.call(params)
    S->>S: Valida e salva Profile
    S->>Q: GithubScraperJob.perform_later
    S->>Q: UrlShortenerJob.perform_later
    C-->>U: Redirect para profile#show

    Note over Q,J: Processamento Assíncrono

    Q->>J: Executa GithubScraperJob
    J->>AC: broadcast(:preparing)
    J->>G: Ferrum navega para github.com/user
    G-->>J: HTML renderizado
    J->>J: HtmlParser extrai dados
    J->>AC: broadcast(:completed)
    AC-->>U: Turbo Stream atualiza UI
```

### 🔄 Pipeline do Scraper

```mermaid
flowchart LR
    A[BrowserManager] --> B[PageValidator]
    B --> C[HtmlParser]
    C --> D[IdentityExtractor]
    C --> E[StatisticsExtractor]
    C --> F[AvatarExtractor]
    C --> G[LocationExtractor]
    C --> H[OrganizationsExtractor]
    D & E & F & G & H --> I[Profile.update!]
    I --> J[Broadcaster]
```

## 💡 Decisões Técnicas

### Blueprinter para Serialização

Escolhi Blueprinter após avaliar as principais alternativas:

| Gem | Req/s | Memória | Dependências | Manutenção |
|-----|-------|---------|--------------|------------|
| **Blueprinter** | ~5000 | Baixa | 0 | Ativa |
| ActiveModel::Serializer | ~3000 | Média | 3 | Lenta |
| JBuilder | ~2500 | Alta | 1 | Ativa |
| FastJsonapi | ~5500 | Baixa | 1 | Descontinuada |

**Por que Blueprinter?**
- Performance comparável ao FastJsonapi, mas ativamente mantido
- DSL intuitiva e flexível com suporte a views
- Zero dependências externas reduz superfície de ataque

### Short.io para Encurtamento de URLs

| Serviço | Limite Gratuito | Domínio Custom | Analytics |
|---------|-----------------|----------------|-----------|
| **Short.io** | 1000/mês | Sim (grátis) | Sim |
| Bitly | 50/mês | Não (pago) | Limitado |
| TinyURL | Ilimitado | Não | Não |

**Por que Short.io?**
- Melhor custo-benefício para MVP
- Adapter Pattern implementado permite trocar provider sem alterar código de negócio
- API bem documentada e estável

### Pagy para Paginação

| Gem | Req/s | Memória | LOC |
|-----|-------|---------|-----|
| **Pagy** | ~5000 | 9KB | ~100 |
| Kaminari | ~500 | 90KB | ~1000 |
| WillPaginate | ~450 | 85KB | ~800 |

**Por que Pagy?**
- 10-20x mais rápido que alternativas
- 90% menos uso de memória
- Totalmente agnóstico (funciona com qualquer ORM/collection)

### Ferrum para Web Scraping

| Gem | JavaScript | Memória | Configuração |
|-----|------------|---------|--------------|
| **Ferrum** | Sim (Chrome) | ~100MB | Média |
| Mechanize | Não | ~20MB | Simples |
| Selenium | Sim | ~150MB | Complexa |
| Watir | Sim | ~150MB | Complexa |

**Por que Ferrum?**
- GitHub renderiza elementos dinamicamente via JavaScript (contribuições, contadores)
- Mechanize não executaria JS, resultando em dados incompletos
- Ferrum é mais leve que Selenium/Watir e tem API Ruby-native

### Dry-Monads para Tratamento de Erros

**Por que Railway Oriented Programming?**
- Tratamento explícito de erros sem exceptions para fluxo de controle
- Composição funcional com `bind` permite pipelines legíveis
- Pattern matching com `Success`/`Failure` torna código previsível
- Facilita testes unitários isolados

## ⚖️ Trade-offs

### Processamento Assíncrono

**Decisão**: Jobs assíncronos com Sidekiq + ActionCable para feedback real-time

**Motivo**:
- Scraping leva 3-5 segundos - bloquearia requisição HTTP
- UX melhorada com modal de progresso e atualizações via WebSocket
- Permite retry automático em caso de falha
- Escalável horizontalmente

**Trade-off**: Complexidade adicional (Redis, Sidekiq, ActionCable) vs UX superior

### Circuit Breaker para Scraping

**Decisão**: Circuit Breaker com Redis para proteger contra falhas consecutivas do GitHub

**Motivo**:
- Evita sobrecarga quando GitHub está indisponível ou com problemas
- Reduz desperdício de recursos (CPU/RAM do Ferrum) em tentativas fadadas ao fracasso
- Recuperação automática após período de timeout (60s)
- Simples e sem dependências extras (usa Redis já existente via Sidekiq)

**Configuração**:
- **Fechado** (closed): Permite scraping normalmente
- **Aberto** (open): Após 5 falhas consecutivas, bloqueia tentativas por 60s
- **Semi-Aberto** (half-open): Após timeout, permite 1 tentativa para testar recuperação

**Trade-off**: Possibilidade de rejeitar requests legítimos durante problemas intermitentes vs proteção contra cascata de falhas

### URL Shortener Externo (Short.io)

**Decisão**: Short.io via Adapter Pattern

**Motivo**:
- MVP rápido - implementação própria bem completa levaria mais tempo
- Analytics incluído gratuitamente
- Adapter Pattern facilita trocar provider no futuro

**Trade-off**: Dependência externa (1000 URLs/mês gratuitas) vs tempo de desenvolvimento

### ViewComponents

**Decisão**: ViewComponents para UI complexa (Cards, Modals, Forms)

**Motivo**:
- Testes unitários isolados (sem Rails.application.call)
- Performance melhorada com caching
- Interface tipada e reutilizável
- Padrão moderno Rails 7+

**Trade-off**: Curva de aprendizado inicial vs testabilidade e manutenibilidade

## ⚠️ Limitações Conhecidas

- **Web Scraping**: Seletores CSS podem quebrar se o GitHub alterar a estrutura HTML
- **Rate Limits**: GitHub pode bloquear por IP; plano gratuito do Short.io limitado a 1000 URLs/mês
- **Escalabilidade**: Ferrum usa ~100MB de RAM por instância de navegador
- **Dados Opcionais**: Alguns perfis podem não ter organização ou localização
- **Cooldown de Re-scan**: Intervalo de 5 minutos entre re-scans

## 🔧 Troubleshooting

### Scraping falha com TimeoutError

```bash
# 1. Verificar se Chrome/Chromium está instalado
which chromium || which google-chrome

# 2. Testar manualmente
CHROME_BIN=$(which chromium || which google-chrome)
echo "Chrome path: $CHROME_BIN"

# 3. Verificar logs do job
bundle exec sidekiq
# Em outro terminal, monitore:
tail -f log/development.log | grep -i scraper
```

### URL Shortening não funciona

```bash
# 1. Verificar variáveis de ambiente
echo "API Key: ${SHORTIO_API_KEY:0:10}..."
echo "Domain: $SHORTIO_DOMAIN"

# 2. Testar API diretamente
curl -X POST "https://api.short.io/links/public" \
  -H "Authorization: $SHORTIO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"originalURL":"https://github.com/matz","domain":"go.short.io"}'

# 3. Verificar rate limit (1000/mês no plano gratuito)
```

### Jobs não estão sendo processados

```bash
# 1. Verificar se Redis está rodando
redis-cli ping  # Deve retornar: PONG

# 2. Verificar conexão do Sidekiq
REDIS_URL=redis://localhost:6379/1 bundle exec sidekiq

# 3. Verificar filas
bundle exec rails runner "puts Sidekiq::Queue.all.map(&:name)"

# 4. Limpar jobs travados (se necessário)
bundle exec rails runner "Sidekiq::RetrySet.new.clear"
```

### ActionCable não atualiza em tempo real

```bash
# 1. Verificar se cable está montado
grep -r "ActionCable" config/routes.rb

# 2. Verificar conexão WebSocket no browser (DevTools > Network > WS)

# 3. Verificar logs do ActionCable
tail -f log/development.log | grep -i cable
```

### Testes falhando localmente

```bash
# 1. Resetar banco de testes
RAILS_ENV=test bundle exec rails db:reset

# 2. Executar com verbose
bundle exec rspec --format documentation

# 3. Executar teste específico isolado
bundle exec rspec spec/services/profiles/github/scraper_service_spec.rb -f d
```

## 🚀 Pontos de Melhoria


### Scraping
- **Circuit Breaker** ✅: Implementado para proteger contra falhas consecutivas do GitHub (fecha após 5 falhas, tenta novamente após 60s)
- **API do GitHub**: Migrar para API oficial do GitHub para dados mais confiáveis (requer autenticação para 5000 req/h)
- **Fallback Strategy**: Implementar fallback automático API → Scraping em caso de falha
- **Health Monitoring**: Sistema de alertas quando seletores CSS falharem
- **Cache Inteligente**: Cachear dados de perfis com TTL configurável para reduzir scraping

### Segurança
- **Autenticação API**: Implementar JWT tokens para acesso à API
- **Autorização**: Adicionar camada de autorização com Pundit ou CanCanCan
- **Criptografia**: Criptografar API keys sensíveis no banco de dados
- **2FA**: Suporte a autenticação de dois fatores

### Observabilidade
- **APM**: Integrar Application Performance Monitoring (New Relic, Datadog, Skylight)
- **Métricas**: Dashboard de métricas com Prometheus + Grafana
- **Error Tracking**: Rastreamento de erros com Sentry ou Honeybadger

### Infraestrutura
- **Kubernetes**: Orquestração de containers para alta disponibilidade
- **Auto-scaling**: Configurar auto-scaling baseado em CPU/memória
- **Infrastructure as Code**: Gerenciar infraestrutura com Terraform

### Performance e Escalabilidade

**Capacidade atual**: ~100 scrapes/h, ~10k perfis

**Gargalos**: Ferrum (~100MB/instância), ILIKE (degrada >50k perfis), Redis single-instance

**Database**:
- Read replicas para queries de leitura
- Connection pooling com PgBouncer
- Índices otimizados para busca

**Cache e Jobs**:
- Redis Cluster para cache distribuído
- Múltiplos workers Sidekiq com filas separadas (`scraping`, `notifications`, `api`)

**Busca**:
- Migrar para Meilisearch quando >50k perfis (10-20x mais rápido que ILIKE)

### Features
- **Webhooks do GitHub**: Receber notificações automáticas de mudanças em perfis
- **Export de Dados**: Permitir exportação de perfis em CSV/JSON
- **Comparação de Perfis**: Funcionalidade para comparar estatísticas entre perfis
- **Notificações**: Sistema de notificações para mudanças significativas em perfis monitorados

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie sua branch de feature (`git checkout -b feature/funcionalidade-incrivel`)
3. Commit suas mudanças (`git commit -m 'Adiciona funcionalidade incrível'`)
4. Push para a branch (`git push origin feature/funcionalidade-incrivel`)
5. Abra um Pull Request

**Requisitos**:
- Testes passando (`bundle exec rspec`)
- Sem offenses do Rubocop (`bundle exec rubocop`)
- Cobertura >90% mantida

## 📄 Licença

Este projeto está licenciado sob a Licença MIT.

## 👨‍💻 Autor

**Renan Gabriel** - [@renangabriel27](https://github.com/renangabriel27)

----

<div align="center">

Desenvolvido com ☕ e 💻

</div>