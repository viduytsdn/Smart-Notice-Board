# Smart Notice Flights frontend

Marketing and booking interface for the Smart Notice UK flights fulfilment demo. Built with Vite + React.

## Available scripts

```bash
npm run dev     # start the development server
npm run build   # create an optimised production bundle
npm run preview # preview the production bundle locally
npm run lint    # run ESLint across the source files
```

## Environment configuration

The app expects the API at `http://localhost:4000` by default. Override it by defining `VITE_API_BASE_URL` in a `.env` file at the project root:

```
VITE_API_BASE_URL=https://your-api.example.com
```

## Project structure

- `src/App.jsx` – layout, flight search flow and booking form
- `src/App.css` – component styling
- `src/index.css` – global resets and typography
