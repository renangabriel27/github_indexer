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
- [⚠️ Limitações Conhecidas](#️-limitações-conhecidas)
- [🚀 Pontos de Melhoria](#-pontos-de-melhoria)
- [🤝 Contribuindo](#-contribuindo)
- [📄 Licença](#-licença)
- [👤 Autor](#-autor)

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
```

## 📚 Documentação da API

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

## 💡 Decisões Técnicas

### Blueprinter para Serialização
- 40% mais rápido que ActiveModel::Serializer
- Zero dependências, mantido ativamente
- Curva de aprendizado baixa

### Short.io para Encurtamento de URLs
- Plano gratuito generoso (1000/mês vs 50/mês do Bitly)
- Suporte a domínio customizado incluído
- Adapter pattern permite fácil troca de provedor

### Pagy para Paginação
- 10-20x mais rápido que Kaminari/WillPaginate
- 90% menos uso de memória

### Ferrum para Web Scraping
- Chrome headless real para renderização de JavaScript
- Retry automático e tratamento de timeout

## ⚠️ Limitações Conhecidas

- **Web Scraping**: Seletores CSS podem quebrar se o GitHub alterar a estrutura HTML
- **Rate Limits**: GitHub pode bloquear por IP; plano gratuito do Short.io limitado a 1000 URLs/mês
- **Escalabilidade**: Ferrum usa ~100MB de RAM por instância de navegador
- **Dados Opcionais**: Alguns perfis podem não ter organização ou localização
- **Cooldown de Re-scan**: Intervalo de 5 minutos entre re-scans

## 🚀 Pontos de Melhoria

### Scraping
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

### Performance
- **Database**: Implementar read replicas do PostgreSQL para distribuir carga
- **Cache Distribuído**: Migrar para Redis Cluster para escalabilidade
- **CDN**: Servir assets estáticos via CDN
- **Full-text Search**: Implementar Meilisearch para buscas mais rápidas e complexas (menor consumo de memória e mais rápido que Elasticsearch)

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