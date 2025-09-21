# Smart Notice Flights (UK Domestic Fulfilment Demo)

A full-stack reference implementation for a UK-only flights fulfilment product. It provides a marketing-led frontend experience, a domestic flights search flow, and a lightweight Express API backed by curated UK routes.

## Project structure

```
./backend   → Express REST API serving UK airports, flights and booking endpoints
./frontend  → Vite + React single-page app that consumes the API and showcases the service
```

## Getting started

### Prerequisites

- Node.js 18+ and npm

### 1. Start the API server

```bash
cd backend
npm install
npm run dev
```

The API listens on `http://localhost:4000` by default and exposes:

- `GET /api/airports` – list of supported UK airports
- `GET /api/flights` – filterable search endpoint (supports `origin`, `destination`, `departureDate`, `maxPrice`)
- `POST /api/bookings` – creates an in-memory booking and returns a confirmation payload

Run `npm run lint` in the backend directory to validate that all flights map to known UK airports.

### 2. Start the frontend

In a new terminal:

```bash
cd frontend
npm install
npm run dev
```

By default the React app expects the API at `http://localhost:4000`. To point to another host, create a `.env` file inside `frontend/` and set:

```
VITE_API_BASE_URL=https://your-hosted-api.example.com
```

### Build commands

- `npm run build` (from `frontend/`) creates a production bundle in `frontend/dist/`.
- `npm run start` (from `backend/`) runs the Express server without hot reload.

## Demo data

The API ships with curated domestic routes located in `backend/data/flights.json` and airports in `backend/data/airports.json`. All routes are strictly UK origin/destination pairs featuring carriers such as British Airways, easyJet, Ryanair, and Loganair. Update these JSON files to extend coverage or integrate with a real data source in place of the static content.

## Next steps

- Replace static data with a live UK GDS or airline NDC feed.
- Connect a persistent database (e.g. PostgreSQL) for booking storage and reporting.
- Add authentication and partner dashboards for agencies managing multiple clients.
