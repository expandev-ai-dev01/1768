# StockBox Backend

Sistema para controlar itens no estoque: entradas, saídas e quantidade atual.

## Technology Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: Microsoft SQL Server
- **Architecture**: REST API

## Project Structure

```
backend/
├── migrations/              # Database migration scripts
├── src/
│   ├── api/                 # API controllers
│   │   └── v1/              # API version 1
│   │       ├── external/    # Public endpoints
│   │       └── internal/    # Authenticated endpoints
│   ├── config/              # Configuration management
│   ├── middleware/          # Express middleware
│   ├── migrations/          # Migration runner
│   ├── routes/              # Route definitions
│   ├── services/            # Business logic
│   ├── utils/               # Utility functions
│   └── server.ts            # Application entry point
├── .env.example             # Environment variables template
├── package.json             # Dependencies and scripts
└── tsconfig.json            # TypeScript configuration
```

## Getting Started

### Prerequisites

- Node.js 18+ installed
- SQL Server instance available
- npm or yarn package manager

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your database credentials
```

3. Run database migrations:
```bash
npm run build
node dist/migrations/run-migrations.js
```

### Development

Start the development server with hot reload:
```bash
npm run dev
```

The API will be available at `http://localhost:3000/api/v1`

### Production Build

Build the application:
```bash
npm run build
```

Start the production server:
```bash
npm start
```

## API Documentation

### Health Check

```
GET /health
```

Returns server health status.

### API Versioning

All API endpoints are versioned:
- V1: `/api/v1/`

### Authentication

Authenticated endpoints require the following headers:
- `x-account-id`: Account identifier
- `x-user-id`: User identifier

## Database Migrations

Migrations are automatically executed on application startup. To run migrations manually:

```bash
ts-node src/migrations/run-migrations.ts
```

To skip migrations on startup:
```bash
SKIP_MIGRATIONS=true npm start
```

## Testing

Run tests:
```bash
npm test
```

Run tests in watch mode:
```bash
npm run test:watch
```

## Code Quality

Run linter:
```bash
npm run lint
```

## Environment Variables

Required environment variables:

- `NODE_ENV`: Environment (development/production)
- `PORT`: Server port (default: 3000)
- `DB_SERVER`: Database server address
- `DB_PORT`: Database port (default: 1433)
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `DB_ENCRYPT`: Enable encryption (true/false)

See `.env.example` for complete list.

## License

ISC