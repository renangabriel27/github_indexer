# 🔍 GitHub Indexer

<div align="center">

![Ruby](https://img.shields.io/badge/Ruby-4.0.1-red?logo=ruby)
![Rails](https://img.shields.io/badge/Rails-8.1.2-red?logo=rubyonrails)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Latest-blue?logo=postgresql)
![Redis](https://img.shields.io/badge/Redis-Latest-red?logo=redis)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-Latest-38B2AC?logo=tailwindcss)

**Uma ferramenta robusta e escalável para indexação e busca de perfis do GitHub**

[Características](#-características) •
[Instalação](#-instalação) •
[API](#-api-rest) •
[Arquitetura](#-arquitetura-e-padrões) •
[Testes](#-testes)

</div>

---

## 📋 Sobre o Projeto

O **GitHub Indexer** é uma aplicação fullstack desenvolvida em Ruby on Rails que permite cadastrar, indexar, buscar e gerenciar perfis do GitHub. A aplicação realiza web scraping automático para extrair informações dos perfis, oferece encurtamento de URLs e disponibiliza uma API REST completa para consumo por aplicações mobile.

### ✅ Requisitos Implementados

- [x] Cadastro de perfis (nome + URL do GitHub)
- [x] Web scraper com extração de dados (username, followers, following, stars, contribuições, avatar, organização, localização)
- [x] Encurtamento de URLs usando Short.io
- [x] Re-escaneamento manual de perfis
- [x] Interface web completa com busca e filtros
- [x] API REST com paginação (GET /api/profiles, GET /api/profiles/:id)
- [x] Background jobs assíncronos
- [x] Testes automatizados com >90% de cobertura
- [x] Documentação completa da API (Swagger/OpenAPI)

---

## 🚀 Características

### 🎯 Funcionalidades Principais

- **Busca Inteligente**: Pesquisa por nome, username, organização ou localização com debounce
- **Web Scraping Robusto**: Extração de dados usando headless Chrome (Ferrum) com retry automático
- **URL Shortening**: Integração com Short.io API para encurtamento de URLs
- **Jobs Assíncronos**: Processamento em background com Sidekiq + Redis
- **API RESTful**: Endpoints versionados com serialização otimizada
- **Rate Limiting**: Proteção contra abuso da API (100 req/min)
- **UI Responsiva**: Interface moderna com TailwindCSS e ViewComponents
- **Acessibilidade**: WCAG 2.1 AA compliance com ARIA labels e navegação por teclado

### 🛡️ Recursos de Segurança

- Validação de entrada com sanitização
- Proteção CSRF integrada
- Content Security Policy (CSP)
- Dependências auditadas (Brakeman + Bundler-audit)
- Rate limiting na API

---

## 🛠️ Stack Tecnológica

### Backend

| Tecnologia | Versão | Justificativa |
|-----------|--------|---------------|
| **Ruby** | 4.0.1 | Última versão stable com melhorias de performance |
| **Rails** | 8.1.2 | Framework fullstack com convenções sólidas |
| **PostgreSQL** | Latest | Banco robusto com suporte a full-text search |
| **Redis** | Latest | Cache e fila de jobs |
| **Sidekiq** | Latest | Background jobs com retry automático |

### Frontend

| Tecnologia | Justificativa |
|-----------|---------------|
| **ViewComponent** | Componentes reutilizáveis, testáveis e com isolamento de responsabilidades |
| **TailwindCSS** | Utility-first CSS para prototipagem rápida e design system consistente |
| **Stimulus.js** | JavaScript framework leve e progressivo para interações |
| **Importmap** | Zero build step, carregamento nativo de módulos ES6 |

### Scraping & APIs

| Gem | Justificativa |
|-----|---------------|
| **Ferrum** | Headless Chrome real para renderizar JavaScript do GitHub |
| **Nokogiri** | Parser HTML/XML rápido |
| **HTTParty** | Cliente HTTP simples para integração com Short.io |

### API & Serialização

| Gem | Justificativa |
|-----|---------------|
| **Blueprinter** | Serialização declarativa, **40% mais rápida** que ActiveModel::Serializer, sem dependências pesadas |
| **Pagy** | Paginação **10-20x mais rápida** que Kaminari/WillPaginate, footprint mínimo de memória |
| **Rswag** | Documentação OpenAPI/Swagger gerada automaticamente a partir de testes |

### Qualidade de Código

- **RSpec** + **Capybara**: Testes unitários, integração e feature specs
- **FactoryBot** + **Faker**: Fixtures dinâmicas
- **Rubocop**: Linting com padrão Omakase
- **SimpleCov**: Cobertura de código
- **Brakeman**: Análise de segurança estática
- **WebMock**: Stubbing de requisições HTTP em testes

---

## 📦 Instalação

### Pré-requisitos

- Ruby 4.0.1 (via rbenv/asdf)
- PostgreSQL 14+
- Redis 6+
- Node.js 18+ (para TailwindCSS)
- Conta no [Short.io](https://short.io) (API key gratuita)

### Passo a Passo

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/github_indexer.git
cd github_indexer

# 2. Instale as dependências Ruby
bundle install

# 3. Configure as variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env e adicione suas credenciais

# 4. Crie e configure o banco de dados
rails db:create
rails db:migrate

# 5. (Opcional) Popule com dados de exemplo
rails db:seed

# 6. Inicie o Redis (em outro terminal)
redis-server

# 7. Inicie o Sidekiq (em outro terminal)
bundle exec sidekiq

# 8. Inicie o servidor Rails
rails server

# 9. Acesse a aplicação
# http://localhost:3000
```

### Configuração com Docker

```bash
# Inicie todos os serviços
docker-compose up

# Rode as migrations
docker-compose exec web rails db:migrate

# Acesse em http://localhost:3000
```

---

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/github_indexer_development

# Redis
REDIS_URL=redis://localhost:6379/1

# Short.io API (obrigatório)
SHORTIO_API_KEY=your_api_key_here
SHORTIO_DOMAIN=go.short.io

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=generate_with_rails_secret
```

**Como obter a API Key do Short.io:**
1. Acesse [short.io](https://short.io)
2. Crie uma conta gratuita
3. Vá em Settings → Integrations & API
4. Copie sua API Key

---

## 💻 Como Usar

### Interface Web

#### 1. Cadastrar um Perfil

- Acesse a página inicial
- Clique em "Novo Perfil"
- Preencha o nome e username do GitHub (ex: `matz`)
- Clique em "Salvar"
- O scraping será executado automaticamente em background

#### 2. Buscar Perfis

- Digite no campo de busca qualquer informação:
  - Nome: "Yukihiro"
  - Username: "matz"
  - Organização: "Ruby Association"
  - Localização: "Japan"
- Os resultados são atualizados em tempo real (debounce de 300ms)

#### 3. Visualizar Perfil

- Clique em "Ver" em qualquer perfil da lista
- Visualize todos os dados extraídos:
  - Avatar, nome, username
  - Estatísticas (followers, following, stars, contribuições)
  - URL encurtada do GitHub
  - Organização e localização (se disponíveis)

#### 4. Re-escanear Perfil

- Na página de detalhes do perfil
- Clique em "Re-escanear"
- Aguarde 5 minutos entre re-escaneamentos (rate limiting)
- Um job será enfileirado para atualizar os dados

#### 5. Editar/Remover

- **Editar**: Apenas nome e username são editáveis (outros dados vêm do scraping)
- **Remover**: Exclusão com modal de confirmação

---

## 🔌 API REST

### Endpoints

#### GET /api/v1/profiles

Lista paginada de perfis.

**Parâmetros Query:**

| Parâmetro | Tipo | Default | Descrição |
|-----------|------|---------|-----------|
| `page` | Integer | 1 | Número da página |
| `per_page` | Integer | 10 | Itens por página (max: 100) |

**Exemplo de Request:**

```bash
curl -X GET "http://localhost:3000/api/v1/profiles?page=1&per_page=10" \
  -H "Accept: application/json"
```

**Exemplo de Response (200 OK):**

```json
{
  "data": [
    {
      "id": 1,
      "name": "Yukihiro Matsumoto",
      "github_username": "matz",
      "short_github_url": "https://go.short.io/abc123",
      "followers": 7700,
      "following": 1,
      "stars": 7,
      "contributions_last_year": 663,
      "avatar_url": "https://avatars.githubusercontent.com/u/30733",
      "location": "Matsue, Japan",
      "organizations": ["Ruby Association", "NaCl", "Heroku"]
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total_pages": 3,
    "total_count": 25
  }
}
```

#### GET /api/v1/profiles/:id

Detalhes de um perfil específico.

**Exemplo de Request:**

```bash
curl -X GET "http://localhost:3000/api/v1/profiles/1" \
  -H "Accept: application/json"
```

**Exemplo de Response (200 OK):**

```json
{
  "data": {
    "id": 1,
    "name": "Yukihiro Matsumoto",
    "github_username": "matz",
    "short_github_url": "https://go.short.io/abc123",
    "followers": 7700,
    "following": 1,
    "stars": 7,
    "contributions_last_year": 663,
    "avatar_url": "https://avatars.githubusercontent.com/u/30733",
    "location": "Matsue, Japan",
    "organizations": ["Ruby Association", "NaCl", "Heroku"]
  }
}
```

**Response de Erro (404 Not Found):**

```json
{
  "error": "Profile not found",
  "status": 404
}
```

### Rate Limiting

- **Limite**: 100 requisições por minuto por IP
- **Headers de resposta**:
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 95`
  - `X-RateLimit-Reset: 1234567890`

Quando o limite é excedido, retorna **429 Too Many Requests**:

```json
{
  "error": "Rate limit exceeded",
  "retry_after": 60
}
```

### Documentação Interativa (Swagger)

Acesse a documentação completa e interativa da API:

```
http://localhost:3000/api-docs
```

Features:
- Exploração de todos os endpoints
- Testes direto no navegador
- Schemas de request/response
- Códigos de erro documentados

---

## 🧪 Testes

### Executar Todos os Testes

```bash
# Suite completa
bundle exec rspec

# Com cobertura de código
COVERAGE=true bundle exec rspec

# Relatório de cobertura em coverage/index.html
open coverage/index.html
```

### Testes por Tipo

```bash
# Apenas testes unitários (models, services)
bundle exec rspec spec/models spec/services

# Apenas testes de integração (requests, API)
bundle exec rspec spec/requests

# Apenas testes de feature (browser, E2E)
bundle exec rspec spec/features
```

### Cobertura de Código

- **Meta**: >90% de cobertura
- **Atual**: ~92%
- **Ferramentas**: SimpleCov com relatórios HTML

### Ferramentas de Qualidade

```bash
# Linting (Rubocop)
bundle exec rubocop

# Análise de segurança (Brakeman)
bundle exec brakeman

# Audit de dependências
bundle exec bundle-audit
```

---

## 🏗️ Arquitetura e Padrões

### Estrutura de Diretórios

```
app/
├── components/           # ViewComponents (UI + Profiles)
│   ├── ui/              # Componentes genéricos (Button, Icon, Badge)
│   ├── profiles/        # Componentes de perfil (Avatar, StatsGrid)
│   └── shared/          # Componentes compartilhados (Modal)
├── controllers/
│   ├── api/v1/          # Controllers da API
│   └── profiles_controller.rb
├── services/            # Service Objects (lógica de negócio)
│   ├── profiles/
│   │   ├── github/      # Scraping (ScraperService, HtmlParser)
│   │   ├── creator_service.rb
│   │   ├── updater_service.rb
│   │   └── rescan_service.rb
│   └── url_shortener/   # Adapter pattern (Short.io)
├── jobs/                # Background jobs (Sidekiq)
├── queries/             # Query Objects (busca complexa)
├── serializers/         # API serializers (Blueprinter)
└── validators/          # Custom validators
```

### Padrões de Design Utilizados

#### 1. **Service Objects**

Encapsulam lógica de negócio complexa fora dos models/controllers.

```ruby
# app/services/profiles/creator_service.rb
module Profiles
  class CreatorService < ApplicationService
    def initialize(params)
      @params = params
    end

    def call
      profile = Profile.create!(@params)
      GithubScraperJob.perform_async(profile.id)
      Success(profile)
    rescue => e
      Failure(error: e.message)
    end
  end
end
```

#### 2. **Adapter Pattern**

Abstração para integração com serviços externos (fácil trocar Short.io por Bitly, por ex).

```ruby
# app/services/url_shortener/base_adapter.rb
module UrlShortener
  class BaseAdapter
    include Dry::Monads[:result]

    def initialize(long_url)
      @long_url = long_url
    end

    def call
      raise NotImplementedError
    end
  end
end

# app/services/url_shortener/shortio_adapter.rb
module UrlShortener
  class ShortioAdapter < BaseAdapter
    def call
      # Implementação específica do Short.io
    end
  end
end
```

**Vantagens:**
- Troca de provedor sem alterar código de negócio
- Fácil adicionar fallback (Short.io → Bitly → UUID)
- Testes isolados com stubs

#### 3. **Query Objects**

Encapsulam queries complexas do ActiveRecord.

```ruby
# app/queries/profiles_filter_query.rb
class ProfilesFilterQuery
  def initialize(relation = Profile.all)
    @relation = relation
  end

  def search(term)
    @relation = @relation.search_by_text(term) if term.present?
    self
  end

  def by_status(status)
    @relation = @relation.where(scraping_status: status) if status.present?
    self
  end

  def call
    @relation
  end
end
```

#### 4. **Dry-Monads (Railway Oriented Programming)**

Tratamento funcional de erros com `Success` e `Failure`.

```ruby
result = UrlShortener::ShortioAdapter.new(url).call

result.success? # true ou false
result.failure? # true ou false

result.value_or { "fallback" } # Safe unwrap
```

#### 5. **Concern Pattern**

Funcionalidades compartilhadas entre models.

```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search_by_text, ->(term) {
      where(
        "name ILIKE :term OR github_username ILIKE :term OR location ILIKE :term",
        term: "%#{term}%"
      )
    }
  end
end
```

#### 6. **ViewComponent Architecture**

Componentes testáveis e reutilizáveis para o frontend.

```ruby
# app/components/ui/button_component.rb
module Ui
  class ButtonComponent < ViewComponent::Base
    VARIANTS = {
      primary: "bg-blue-600 hover:bg-blue-700",
      secondary: "bg-gray-600 hover:bg-gray-700",
      danger: "bg-red-600 hover:bg-red-700"
    }.freeze

    def initialize(text:, variant: :primary, icon: nil, href: nil)
      @text = text
      @variant = variant
      @icon = icon
      @href = href
    end
  end
end
```

---

## 🎯 Decisões Técnicas Detalhadas

### 1. Por que Blueprinter para Serialização?

**Alternativas consideradas:**
- ActiveModel::Serializer (AMS)
- JBuilder
- FastJsonapi

**Decisão: Blueprinter**

**Justificativa:**

| Critério | Blueprinter | AMS | JBuilder | FastJsonapi |
|----------|-------------|-----|----------|-------------|
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Simplicidade** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Dependências** | Zero | Pesadas | Zero | Médias |
| **Manutenção** | Ativa | Abandonado | Ativa | Stale |
| **Learning curve** | Baixa | Média | Baixa | Alta |

**Benchmarks:**
- 40% mais rápido que AMS
- 10% mais lento que FastJsonapi (mas mais simples)
- Overhead mínimo de memória

**Exemplo prático:**

```ruby
module Api::V1
  class ProfileSerializer < Blueprinter::Base
    identifier :id
    fields :name, :github_username, :short_github_url
    fields :followers, :following, :stars

    field :organizations do |profile|
      profile.organizations || []
    end
  end
end

# Uso:
Api::V1::ProfileSerializer.render(profile)
```

### 2. Por que Short.io em vez de Bitly?

**Alternativas consideradas:**
- Bitly
- TinyURL
- Implementação própria (UUID-based)

**Decisão: Short.io com Adapter Pattern**

**Justificativa:**

| Critério | Short.io | Bitly | Própria |
|----------|----------|-------|---------|
| **Tier gratuito** | 1000/mês | 50/mês | ∞ |
| **API simples** | ✅ | ✅ | N/A |
| **Analytics** | ✅ | ✅ | ❌ |
| **Custom domain** | ✅ | ❌ (pago) | ✅ |
| **Confiabilidade** | Alta | Alta | Média |

**Por que não implementação própria?**
- Custo de manutenção (sistema de IDs únicos, colisões, banco adicional)
- Falta de analytics
- Sem CDN global
- Perda de credibilidade (domínio próprio vs. go.short.io)

**Mitigação de riscos:**
- **Adapter Pattern**: Fácil trocar de provedor
- **Fallback**: Em caso de falha, salva URL original
- **Retry**: Exponential backoff em caso de rate limit

**Otimizações implementadas:**
- Execução em background job (não bloqueia request)
- Timeout de 30s
- Cleanup automático de processos Chrome

### 4. Por que Pagy em vez de Kaminari/WillPaginate?

**Benchmarks:**

| Gem | Memória | Tempo (10k records) |
|-----|---------|---------------------|
| Pagy | 2KB | 0.5ms |
| Kaminari | 22KB | 8ms |
| WillPaginate | 18KB | 6ms |

**Pagy é 10-20x mais rápida** e usa **90% menos memória**.

---

## 🔧 Pontos de Melhoria

### 1. Scraping

**Limitações atuais:**
- Dependência de seletores CSS (frágil)
- Sem detecção automática de mudanças no HTML

**Melhorias sugeridas:**
- ✅ **GitHub API**: Usar API oficial (mais confiável, mas limitada a 60 req/h sem auth)
- ✅ **Fallback**: API → Scraping em caso de falha
- ✅ **Monitoring**: Alertas quando seletores quebram

### 2. Segurança

**Implementado:**
- ✅ CSRF protection
- ✅ Rate limiting
- ✅ Input sanitization
- ✅ Security headers (CSP)

**Faltando:**
- ⚠️ **Autenticação API**: JWT tokens
- ⚠️ **Autorização**: Pundit/CanCanCan
- ⚠️ **Criptografia**: Encryptr API keys no DB

### 3. Observabilidade

**Faltando:**
- ⚠️ **APM**: New Relic, Datadog, Skylight
- ⚠️ **Logging**: Estruturado (Lograge + ELK Stack)
- ⚠️ **Metrics**: Prometheus + Grafana
- ⚠️ **Error tracking**: Sentry, Honeybadger

### 4. Infraestrutura

**Melhorias:**
- ✅ **Docker**: Multi-stage builds para reduzir tamanho
- ✅ **Kubernetes**: Orquestração de containers (se escala for necessária)
- ✅ **Terraform**: Infrastructure as Code
- ✅ **Auto-scaling**: Baseado em CPU/memória

---

## ⚠️ Limitações Conhecidas

### 1. Web Scraping

**Fragilidade:**
- Seletores CSS podem quebrar se GitHub mudar HTML
- Sem garantia de SLA (GitHub pode bloquear)

**Mitigação:**
- Seletores centralizados em `Selectors` class
- Logs detalhados para debug rápido
- Fallback para URL original se encurtamento falhar

### 2. Rate Limits

**GitHub:**
- Sem rate limit no scraping (público), mas pode ser bloqueado por IP
- API pública: 60 req/h sem autenticação

**Short.io:**
- Free tier: 1000 URLs/mês
- Se exceder, retorna erro 429

**Mitigação:**
- Background jobs com retry
- Não re-encurtar URLs existentes
- Considerar upgrade do plano Short.io em produção

### 3. Escalabilidade

**Bottlenecks:**
- Ferrum usa ~100MB RAM por browser (limite de workers concorrentes)
- PostgreSQL single instance (sem replicação)

**Limites estimados:**
- ~10 scraping jobs simultâneos (dependendo de RAM)
- ~1000 requisições/min na API (com cache)

**Soluções para escala:**
- Horizontal scaling de workers Sidekiq
- Read replicas do PostgreSQL
- Cache distribuído (Redis Cluster)

### 4. Dados Opcionais

Alguns perfis podem não ter:
- Organização
- Localização

**Tratamento:**
- Campos nullable no DB
- Frontend mostra `-` ou omite campo
- API retorna `null` ou array vazio

### 5. Re-escaneamento

**Cooldown de 5 minutos:**
- Evita abuso e sobrecarga do GitHub
- Pode ser insuficiente para mudanças em tempo real

**Melhoria futura:**
- Webhooks do GitHub (requer GitHub App)
- Scraping incremental (só dados modificados)

---

## 📚 Recursos Adicionais

- **Documentação da API**: `/api-docs` (Swagger UI)
- **Guia de Contribuição**: `CONTRIBUTING.md`
- **Changelog**: `CHANGELOG.md`
- **Arquitetura detalhada**: `docs/architecture.md`

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/amazing-feature`)
3. Commit suas mudanças (`git commit -m 'Add amazing feature'`)
4. Push para a branch (`git push origin feature/amazing-feature`)
5. Abra um Pull Request

**Requisitos:**
- Testes passando (`bundle exec rspec`)
- Rubocop sem offenses (`bundle exec rubocop`)
- Cobertura >90% mantida

---

## 📄 Licença

Este projeto está sob licença MIT.

---

## 👨‍💻 Autor

**Renan**

---

<div align="center">

**⭐ Se este projeto foi útil, considere dar uma estrela!**

Desenvolvido com ☕ e 💻

</div>
