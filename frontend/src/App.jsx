import { useEffect, useMemo, useState } from 'react';
import './App.css';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000';

const valueProps = [
  {
    title: 'Domestic specialists',
    description: 'Non-stop coverage of all major UK mainland and island routes with live seat availability.'
  },
  {
    title: 'Transparent fares',
    description: 'Final price in pounds sterling, including air passenger duty and hand-luggage as standard.'
  },
  {
    title: 'ATOL-ready checkout',
    description: 'Designed for ATOL bonded agencies with secure payment gateways and invoice exports.'
  },
];

const quickDeals = [
  {
    route: 'London ✈ Edinburgh',
    blurb: 'Business day return with morning and evening frequencies.',
  },
  {
    route: 'Manchester ✈ Belfast',
    blurb: 'Weekend seats with hand luggage from £52 each way.',
  },
  {
    route: 'Glasgow ✈ Southampton',
    blurb: 'Seasonal flights for cruise departures and south coast escapes.',
  },
];

function FlightCard({ flight, onSelect }) {
  const departureDate = new Date(flight.departure);
  const arrivalDate = new Date(flight.arrival);

  const departureLabel = departureDate.toLocaleTimeString('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
  });
  const arrivalLabel = arrivalDate.toLocaleTimeString('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
  });
  const dateLabel = departureDate.toLocaleDateString('en-GB', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
  });

  return (
    <article className="flight-card">
      <header>
        <h3>{flight.airline}</h3>
        <p className="flight-number">{flight.flightNumber}</p>
      </header>
      <div className="flight-times">
        <div>
          <span className="time">{departureLabel}</span>
          <span className="airport">{flight.origin}</span>
        </div>
        <div className="duration">{Math.round(flight.durationMinutes)} mins</div>
        <div>
          <span className="time">{arrivalLabel}</span>
          <span className="airport">{flight.destination}</span>
        </div>
      </div>
      <p className="flight-date">{dateLabel}</p>
      <p className="flight-meta">
        {flight.cabinClass} · {flight.seatsAvailable} seats left
      </p>
      <div className="flight-footer">
        <div>
          <p className="price">£{flight.price.toFixed(2)}</p>
          <p className="taxes">incl. taxes & fees</p>
        </div>
        <button className="primary" type="button" onClick={() => onSelect(flight)}>
          Reserve seats
        </button>
      </div>
    </article>
  );
}

function BookingForm({ flight, onClose, onSubmit, status }) {
  const [leadPassenger, setLeadPassenger] = useState('');
  const [email, setEmail] = useState('');
  const [quantity, setQuantity] = useState(1);

  const total = useMemo(() => {
    return (flight?.price || 0) * quantity;
  }, [flight, quantity]);

  useEffect(() => {
    setQuantity(1);
    setLeadPassenger('');
    setEmail('');
  }, [flight?.id]);

  const handleSubmit = (event) => {
    event.preventDefault();
    if (!flight) return;
    onSubmit({
      flightId: flight.id,
      passengers: new Array(Number(quantity)).fill(null).map((_, index) => ({
        name: index === 0 && leadPassenger ? leadPassenger : `Passenger ${index + 1}`,
      })),
      contact: {
        email: email || null,
        leadPassenger: leadPassenger || null,
      },
    });
  };

  return (
    <section className="booking-panel">
      <div className="booking-header">
        <h3>Reserve {flight.origin} → {flight.destination}</h3>
        <button type="button" onClick={onClose} className="link">
          Cancel
        </button>
      </div>
      <p className="booking-subheading">
        Secure seats instantly. We will send the confirmation and payment link to your email.
      </p>
      <form className="booking-form" onSubmit={handleSubmit}>
        <label>
          Lead passenger name
          <input
            type="text"
            placeholder="e.g. Alex Johnson"
            value={leadPassenger}
            onChange={(event) => setLeadPassenger(event.target.value)}
            required
          />
        </label>
        <label>
          Contact email
          <input
            type="email"
            placeholder="you@example.co.uk"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            required
          />
        </label>
        <label>
          Seats to reserve
          <input
            type="number"
            min="1"
            max={flight.seatsAvailable}
            value={quantity}
            onChange={(event) => setQuantity(Number(event.target.value))}
          />
        </label>
        <div className="booking-total">
          <span>Total</span>
          <span>£{total.toFixed(2)}</span>
        </div>
        <button type="submit" className="primary" disabled={status === 'loading'}>
          {status === 'loading' ? 'Processing…' : 'Confirm provisional booking'}
        </button>
        {status === 'error' && (
          <p className="error">Unable to create booking. Please try again.</p>
        )}
      </form>
    </section>
  );
}

function App() {
  const [airports, setAirports] = useState([]);
  const [loadingAirports, setLoadingAirports] = useState(true);
  const [searchForm, setSearchForm] = useState({
    origin: '',
    destination: '',
    departureDate: new Date().toISOString().split('T')[0],
    maxPrice: '',
  });
  const [searching, setSearching] = useState(false);
  const [flights, setFlights] = useState([]);
  const [error, setError] = useState('');
  const [selectedFlight, setSelectedFlight] = useState(null);
  const [bookingStatus, setBookingStatus] = useState('idle');
  const [bookingResponse, setBookingResponse] = useState(null);

  useEffect(() => {
    async function fetchAirports() {
      setLoadingAirports(true);
      try {
        const response = await fetch(`${API_BASE_URL}/api/airports`);
        if (!response.ok) throw new Error('Failed to load airports');
        const data = await response.json();
        setAirports(
          data.sort((a, b) => a.city.localeCompare(b.city) || a.name.localeCompare(b.name))
        );
      } catch (err) {
        console.error(err);
        setError('Unable to load airport list. Refresh to try again.');
      } finally {
        setLoadingAirports(false);
      }
    }

    fetchAirports();
  }, []);

  const handleFieldChange = (field) => (event) => {
    setSearchForm((prev) => ({
      ...prev,
      [field]: event.target.value,
    }));
  };

  const handleSearch = async (event) => {
    event.preventDefault();
    setSearching(true);
    setError('');
    setSelectedFlight(null);
    setBookingResponse(null);

    const params = new URLSearchParams();
    if (searchForm.origin) params.append('origin', searchForm.origin);
    if (searchForm.destination) params.append('destination', searchForm.destination);
    if (searchForm.departureDate) params.append('departureDate', searchForm.departureDate);
    if (searchForm.maxPrice) params.append('maxPrice', searchForm.maxPrice);

    try {
      const response = await fetch(`${API_BASE_URL}/api/flights?${params.toString()}`);
      if (!response.ok) throw new Error('Search failed');
      const data = await response.json();
      setFlights(data.flights);
    } catch (err) {
      console.error(err);
      setError('We could not find flights right now. Please adjust filters or try later.');
    } finally {
      setSearching(false);
    }
  };

  const handleBooking = async ({ flightId, passengers, contact }) => {
    setBookingStatus('loading');
    setBookingResponse(null);

    try {
      const response = await fetch(`${API_BASE_URL}/api/bookings`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ flightId, passengers, contact }),
      });

      if (!response.ok) throw new Error('Booking failed');
      const data = await response.json();
      setBookingResponse(data);
      setBookingStatus('success');
    } catch (err) {
      console.error(err);
      setBookingStatus('error');
    }
  };

  const resetBooking = () => {
    setSelectedFlight(null);
    setBookingResponse(null);
    setBookingStatus('idle');
  };

  return (
    <div className="app">
      <header className="topbar">
        <div className="container">
          <div className="brand">Smart Notice Flights</div>
          <nav>
            <a href="#search">Search</a>
            <a href="#value">Why us</a>
            <a href="#contact">Contact</a>
          </nav>
        </div>
      </header>

      <main>
        <section className="hero" id="search">
          <div className="container">
            <div className="hero-copy">
              <p className="eyebrow">UK DOMESTIC SPECIALISTS</p>
              <h1>Search, reserve and fulfil UK flights in one place.</h1>
              <p className="tagline">
                From London hops to island connectors, build itineraries with trusted suppliers and ATOL-ready processes.
              </p>
              <ul className="highlights">
                <li>Live seat availability from national and regional airlines.</li>
                <li>Digital documentation and customer comms in under two minutes.</li>
                <li>Designed for TMCs, concierge teams and independent agents.</li>
              </ul>
            </div>
            <div className="search-card">
              <h2>Plan a domestic itinerary</h2>
              <form onSubmit={handleSearch} className="search-form">
                <label>
                  From
                  <select value={searchForm.origin} onChange={handleFieldChange('origin')} required>
                    <option value="" disabled>
                      Select departure airport
                    </option>
                    {airports.map((airport) => (
                      <option key={airport.code} value={airport.code}>
                        {airport.city} ({airport.code})
                      </option>
                    ))}
                  </select>
                </label>
                <label>
                  To
                  <select
                    value={searchForm.destination}
                    onChange={handleFieldChange('destination')}
                    required
                  >
                    <option value="" disabled>
                      Choose arrival airport
                    </option>
                    {airports
                      .filter((airport) => airport.code !== searchForm.origin)
                      .map((airport) => (
                        <option key={airport.code} value={airport.code}>
                          {airport.city} ({airport.code})
                        </option>
                      ))}
                  </select>
                </label>
                <label>
                  Departure date
                  <input
                    type="date"
                    value={searchForm.departureDate}
                    min={new Date().toISOString().split('T')[0]}
                    onChange={handleFieldChange('departureDate')}
                    required
                  />
                </label>
                <label>
                  Max budget (optional)
                  <input
                    type="number"
                    min="0"
                    step="10"
                    placeholder="e.g. 150"
                    value={searchForm.maxPrice}
                    onChange={handleFieldChange('maxPrice')}
                  />
                </label>
                <button className="primary" type="submit" disabled={searching || loadingAirports}>
                  {searching ? 'Searching…' : 'Find flights'}
                </button>
              </form>
              {error && <p className="error">{error}</p>}
              {loadingAirports && <p className="muted">Loading airports…</p>}
            </div>
          </div>
        </section>

        <section className="results" id="results">
          <div className="container">
            <header className="section-header">
              <h2>Available services</h2>
              <p>Direct content from UK airlines and regional partners.</p>
            </header>
            {searching && <p>Searching for flights…</p>}
            {!searching && flights.length === 0 && (
              <p className="muted">Search for a route to see available flights.</p>
            )}
            <div className="grid">
              {flights.map((flight) => (
                <FlightCard key={flight.id} flight={flight} onSelect={setSelectedFlight} />
              ))}
            </div>

            {selectedFlight && bookingStatus !== 'success' && (
              <BookingForm
                flight={selectedFlight}
                onClose={resetBooking}
                onSubmit={handleBooking}
                status={bookingStatus}
              />
            )}

            {bookingStatus === 'success' && bookingResponse && (
              <div className="success-panel">
                <h3>Booking created</h3>
                <p>
                  Reference <strong>{bookingResponse.booking.id}</strong> has been issued for{' '}
                  {bookingResponse.booking.passengers.length} passenger(s).
                </p>
                <p>
                  A confirmation email will be sent to <strong>{bookingResponse.booking.contact?.email}</strong>.
                </p>
                <button type="button" className="secondary" onClick={resetBooking}>
                  Book another flight
                </button>
              </div>
            )}
          </div>
        </section>

        <section className="value" id="value">
          <div className="container">
            <header className="section-header">
              <h2>Built around UK travel buyers</h2>
              <p>Deliver consistent service for domestic travellers with fulfilment playbooks baked in.</p>
            </header>
            <div className="grid value-grid">
              {valueProps.map((item) => (
                <article key={item.title} className="value-card">
                  <h3>{item.title}</h3>
                  <p>{item.description}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="deals">
          <div className="container">
            <header className="section-header">
              <h2>Trending domestic sectors</h2>
              <p>Recommended for corporate shuttles, group trips and urgent last-minute bookings.</p>
            </header>
            <div className="grid deal-grid">
              {quickDeals.map((deal) => (
                <article key={deal.route} className="deal-card">
                  <h3>{deal.route}</h3>
                  <p>{deal.blurb}</p>
                </article>
              ))}
            </div>
          </div>
        </section>
      </main>

      <footer id="contact">
        <div className="container">
          <div>
            <h4>Talk to our team</h4>
            <p>
              Email <a href="mailto:hello@smartnoticeflights.co.uk">hello@smartnoticeflights.co.uk</a> or call 0203 000 1234 for API access and onboarding.
            </p>
          </div>
          <div className="footer-links">
            <a href="#search">Search flights</a>
            <a href="#value">Why choose us</a>
            <a href="#contact">Contact</a>
          </div>
          <p className="copyright">© {new Date().getFullYear()} Smart Notice Flights. ATOL & ABTA support ready.</p>
        </div>
      </footer>
    </div>
  );
}

export default App;
