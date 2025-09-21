const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const { parseISO, isSameDay } = require('date-fns');

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

const airportsPath = path.join(__dirname, '..', 'data', 'airports.json');
const flightsPath = path.join(__dirname, '..', 'data', 'flights.json');

let airports = [];
let flights = [];
let bookings = [];

function loadData() {
  try {
    const airportRaw = fs.readFileSync(airportsPath, 'utf-8');
    const flightsRaw = fs.readFileSync(flightsPath, 'utf-8');
    airports = JSON.parse(airportRaw);
    flights = JSON.parse(flightsRaw);
  } catch (error) {
    console.error('Failed to load data files', error);
  }
}

loadData();

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Smart Notice UK flights API ready' });
});

app.get('/api/airports', (req, res) => {
  res.json(airports);
});

app.get('/api/flights', (req, res) => {
  const { origin, destination, departureDate, airline, maxPrice } = req.query;

  let filtered = [...flights];

  if (origin) {
    filtered = filtered.filter((flight) => flight.origin === origin.toUpperCase());
  }

  if (destination) {
    filtered = filtered.filter((flight) => flight.destination === destination.toUpperCase());
  }

  if (departureDate) {
    filtered = filtered.filter((flight) => {
      try {
        return isSameDay(parseISO(flight.departure), parseISO(departureDate));
      } catch (error) {
        return false;
      }
    });
  }

  if (airline) {
    filtered = filtered.filter((flight) =>
      flight.airline.toLowerCase().includes(String(airline).toLowerCase())
    );
  }

  if (maxPrice) {
    const ceiling = Number(maxPrice);
    if (!Number.isNaN(ceiling)) {
      filtered = filtered.filter((flight) => flight.price <= ceiling);
    }
  }

  res.json({
    count: filtered.length,
    flights: filtered,
  });
});

app.get('/api/flights/:id', (req, res) => {
  const flight = flights.find((item) => item.id === req.params.id);
  if (!flight) {
    return res.status(404).json({ message: 'Flight not found' });
  }

  res.json(flight);
});

app.post('/api/bookings', (req, res) => {
  const { flightId, passengers, contact } = req.body || {};

  if (!flightId || !Array.isArray(passengers) || passengers.length === 0) {
    return res.status(400).json({ message: 'Flight ID and at least one passenger are required' });
  }

  const flight = flights.find((item) => item.id === flightId);
  if (!flight) {
    return res.status(404).json({ message: 'Flight not found' });
  }

  if (passengers.length > flight.seatsAvailable) {
    return res.status(400).json({
      message: 'Not enough seats available',
      seatsAvailable: flight.seatsAvailable,
    });
  }

  const bookingReference = `UK-${Date.now().toString(36).toUpperCase()}`;

  const newBooking = {
    id: bookingReference,
    flightId,
    passengers,
    contact: contact || null,
    totalPrice: Number((flight.price * passengers.length).toFixed(2)),
    currency: flight.currency,
    createdAt: new Date().toISOString(),
  };

  bookings.push(newBooking);

  res.status(201).json({
    message: 'Booking confirmed',
    booking: newBooking,
    flight,
  });
});

app.get('/api/bookings/:id', (req, res) => {
  const booking = bookings.find((item) => item.id === req.params.id);
  if (!booking) {
    return res.status(404).json({ message: 'Booking not found' });
  }

  const flight = flights.find((item) => item.id === booking.flightId) || null;

  res.json({ booking, flight });
});

app.listen(PORT, () => {
  console.log(`Smart Notice UK Flights API running on port ${PORT}`);
});

module.exports = app;
