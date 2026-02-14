import React from "react";

const authBase = import.meta.env.VITE_AUTH_URL || "/auth";
const catalogBase = import.meta.env.VITE_CATALOG_URL || "/catalog";

const defaultItems = [
  {
    name: "Terraform State Guard",
    type: "Infrastructure",
    desc: "Validates remote state drift and enforces tagging policy before deploy."
  },
  {
    name: "ECS Cost Radar",
    type: "FinOps",
    desc: "Summarizes service-level cost drivers and idle capacity."
  },
  {
    name: "Blue-Green Orchestrator",
    type: "Delivery",
    desc: "Automates canary cutovers with health-aware rollbacks."
  }
];

async function fetchCatalog() {
  const res = await fetch(`${catalogBase}/items`);
  if (!res.ok) throw new Error("Catalog fetch failed");
  const data = await res.json();
  return data.items || defaultItems;
}

async function fetchCatalogStats() {
  const res = await fetch(`${catalogBase}/stats`);
  if (!res.ok) throw new Error("Catalog stats failed");
  return res.json();
}

async function login(payload) {
  const res = await fetch(`${authBase}/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });
  if (!res.ok) {
    throw new Error("Login failed");
  }
  return res.json();
}

export default function App() {
  const [items, setItems] = React.useState([]);
  const [status, setStatus] = React.useState({ type: "", msg: "" });
  const [form, setForm] = React.useState({ username: "", password: "" });
  const [source, setSource] = React.useState("unknown");
  const [stats, setStats] = React.useState(null);

  /* React.useEffect(() => {
    Promise.all([fetchCatalog(), fetchCatalogStats()])
      .then(([fetchedItems, fetchedStats]) => {
        setItems(fetchedItems);
        setStats(fetchedStats);
        const isLive = fetchedItems.some((item) => item.id || item.tier);
        setSource(isLive ? "live" : "fallback");
      })
      .catch(() => {
        setItems(defaultItems);
        setStats(null);
        setSource("fallback");
      });
  }, []); */

  async function loadCatalog() {
  try {
    const [fetchedItems, fetchedStats] = await Promise.all([
      fetchCatalog(),
      fetchCatalogStats()
    ]);
    setItems(fetchedItems);
    setStats(fetchedStats);
    const isLive = fetchedItems.some((item) => item.id || item.tier);
    setSource(isLive ? "live" : "fallback");
  } catch {
    setItems(defaultItems);
    setStats(null);
    setSource("fallback");
  }
}

  async function onSubmit(e) {
    e.preventDefault();
    setStatus({ type: "", msg: "" });
    try {
      const data = await login(form);
      setStatus({ type: "ok", msg: `Authenticated. Token: ${data.token.slice(0, 16)}...` });
    } catch {
      setStatus({ type: "err", msg: "Invalid credentials or auth service unavailable." });
    }
  }

  return (
    <div className="page">
      <header className="hero">
        <div className="hero__content">
          <p className="tag">Cloud + DevOps Microservices</p>
          <h1>Operate fast, deploy safer, and scale with clarity.</h1>
          <p className="lead">
            A responsive front-end that connects an Auth service and a Catalog service.
            Built for ECS microservices and DevOps workflows.
          </p>
          <div className="hero__actions">
            <a className="btn primary" href="#login">Try Login</a>
            <a className="btn ghost" href="#catalog" onClick={loadCatalog}>Catalog</a>
          </div>
        </div>
        <div className="hero__panel">
          <div className="panel-card">
            <h3>Live Service Health</h3>
            <p>Frontend, Auth, Catalog</p>
            <div className="status-grid">
              <span className="pill ok">Frontend</span>
              <span className="pill warn">Auth</span>
              <span className="pill ok">Catalog</span>
            </div>
            <div className="panel-metric">
              <span>Deploy Latency</span>
              <strong>2m 12s</strong>
            </div>
            <div className="panel-metric">
              <span>Rollback Ready</span>
              <strong>Yes</strong>
            </div>
          </div>
        </div>
      </header>

      <section className="grid">
        <article className="card">
          <h3>React Frontend</h3>
          <p>Responsive UI, lightweight fetch client, environment-based routing.</p>
          <ul>
            <li>Vite build</li>
            <li>SPA routing ready</li>
            <li>Deployable via Nginx</li>
          </ul>
        </article>
        <article className="card">
          <h3>Auth Service (Node)</h3>
          <p>Simple JWT-based login with CORS and health check.</p>
          <ul>
            <li>Express</li>
            <li>JWT tokens</li>
            <li>/auth/login</li>
          </ul>
        </article>
        <article className="card">
          <h3>Catalog Service (Python)</h3>
          <p>Cloud/DevOps catalog listing with health endpoint.</p>
          <ul>
            <li>FastAPI</li>
            <li>/catalog/items</li>
            <li>Structured JSON</li>
          </ul>
        </article>
      </section>

      <section id="login" className="split">
        <div>
          <h2>Login to Auth Service</h2>
          <p>
            Use any username and password to get a demo token.
            This is a dev-friendly endpoint for wiring ECS services together.
          </p>
          <form className="login" onSubmit={onSubmit}>
            <label>
              Username
              <input
                value={form.username}
                onChange={(e) => setForm({ ...form, username: e.target.value })}
                placeholder="cloudops"
                required
              />
            </label>
            <label>
              Password
              <input
                type="password"
                value={form.password}
                onChange={(e) => setForm({ ...form, password: e.target.value })}
                placeholder="������"
                required
              />
            </label>
            <button className="btn primary" type="submit">
              Authenticate
            </button>
            {status.msg && (
              <div className={`status ${status.type}`}>{status.msg}</div>
            )}
          </form>
        </div>
        <div className="side-card">
          <h3>Security Notes</h3>
          <p>
            Tokens are short-lived and signed locally for demo usage.
            Wire a real IdP later without changing frontend contracts.
          </p>
          <div className="side-list">
            <span>OIDC-ready</span>
            <span>JWT tokens</span>
            <span>Health probes</span>
          </div>
        </div>
      </section>

      <section id="catalog" className="catalog">
        <div className="catalog-head">
          <div>
            <h2>Cloud & DevOps Catalog</h2>
            <p>
              Live items coming from the Catalog microservice.
              If the service is unavailable, static items are shown instead.
            </p>
          </div>
          <div className={`source-badge ${source === "live" ? "live" : "fallback"}`}>
            {source === "live" ? "Live microservice" : "Fallback data"}
          </div>
        </div>

        {stats && (
          <div className="stats-grid">
            <div className="stat-card">
              <span>Total Items</span>
              <strong>{stats.total}</strong>
            </div>
            <div className="stat-card">
              <span>Core Tier</span>
              <strong>{stats.by_tier?.core || 0}</strong>
            </div>
            <div className="stat-card">
              <span>Extended Tier</span>
              <strong>{stats.by_tier?.extended || 0}</strong>
            </div>
          </div>
        )}

        <div className="catalog-grid">
          {items.map((item) => (
            <article className={`catalog-card ${item.tier ? "live" : "fallback"}`} key={item.name}>
              <div className="catalog-top">
                <h4>{item.name}</h4>
                {item.id && <span className="mini-tag">{item.id}</span>}
              </div>
              <span className="badge">{item.type}</span>
              {item.tier && <span className="tier-tag">{item.tier}</span>}
              <p>{item.desc}</p>
            </article>
          ))}
        </div>
      </section>

      <footer className="footer">
        <p>Built for ECS microservices deployment.</p>
      </footer>
    </div>
  );
}