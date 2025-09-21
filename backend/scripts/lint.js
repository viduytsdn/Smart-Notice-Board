const fs = require('fs');
const path = require('path');

const airportsPath = path.join(__dirname, '..', 'data', 'airports.json');
const flightsPath = path.join(__dirname, '..', 'data', 'flights.json');

function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

try {
  const airports = loadJson(airportsPath);
  const flights = loadJson(flightsPath);
  const airportCodes = new Set(airports.map((airport) => airport.code));

  const invalidFlights = flights.filter(
    (flight) => !airportCodes.has(flight.origin) || !airportCodes.has(flight.destination)
  );

  if (invalidFlights.length > 0) {
    console.error('Invalid flights detected:', invalidFlights);
    process.exit(1);
  }

  console.log('Lint OK: all flights map to recognised UK airports.');
} catch (error) {
  console.error('Lint failed:', error.message);
  process.exit(1);
}
