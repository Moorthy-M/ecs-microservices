import React from "react";

const authBase = import.meta.env.VITE_AUTH_URL || "/auth";
const catalogBase = import.meta.env.VITE_CATALOG_URL || "/catalog";

const defaultItems = [
  {
    name: "Terraform State Guard",
    type: "Infrastructure",
    desc: "Validates remote state drift and enforces tagging policy before deploy.",
  },
  {
    name: "ECS Cost Radar",
    type: "FinOps",
    desc: "Summarizes service-level cost drivers and idle capacity.",
  },
  {
    name: "Blue-Green Orchestrator",
    type: "Delivery",
    desc: "Automates canary cutovers with health-aware rollbacks.",
  },
];

async function parseJsonOrEmpty(res) {
  try {
    return await res.json();
  } catch {
    return {};
  }
}

async function login(payload) {
  const res = await fetch(`${authBase}/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  const data = await parseJsonOrEmpty(res);
  if (!res.ok) throw new Error(data.error || "login_failed");
  return data;
}

async function signup(payload) {
  const res = await fetch(`${authBase}/signup`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  const data = await parseJsonOrEmpty(res);
  if (!res.ok) throw new Error(data.error || "signup_failed");
  return data;
}

async function fetchCatalog() {
  const res = await fetch(`${catalogBase}/items`);
  if (!res.ok) throw new Error("catalog_fetch_failed");
  const data = await res.json();
  return data.items || defaultItems;
}

async function fetchCatalogStats() {
  const res = await fetch(`${catalogBase}/stats`);
  if (!res.ok) throw new Error("catalog_stats_failed");
  return res.json();
}

export default function App() {
  const [items, setItems] = React.useState(defaultItems);
  const [status, setStatus] = React.useState({ type: "", msg: "" });
  const [authMode, setAuthMode] = React.useState("login");
  const [currentUser, setCurrentUser] = React.useState(null);
  const [loginForm, setLoginForm] = React.useState({ username: "", password: "" });
  const [signupForm, setSignupForm] = React.useState({ username: "", email: "", password: "" });
  const [source, setSource] = React.useState("fallback");
  const [stats, setStats] = React.useState(null);
  const [catalogMsg, setCatalogMsg] = React.useState("Showing fallback catalog. Click the button to load live data.");

  function switchAuthMode(mode) {
    setAuthMode(mode);
    setCurrentUser(null);
    setStatus({ type: "", msg: "" });
  }

  async function loadCatalog() {
    try {
      const [fetchedItems, fetchedStats] = await Promise.all([fetchCatalog(), fetchCatalogStats()]);
      setItems(fetchedItems);
      setStats(fetchedStats);
      const isLive = fetchedItems.some((item) => item.id || item.tier);
      setSource(isLive ? "live" : "fallback");
      setCatalogMsg(
        isLive
          ? "Live catalog loaded from microservice."
          : "Catalog service returned fallback/default data.",
      );
    } catch {
      setItems(defaultItems);
      setStats(null);
      setSource("fallback");
      setCatalogMsg("Catalog service unavailable. Showing fallback/default data.");
    }
  }

  async function onLoginSubmit(e) {
    e.preventDefault();
    setStatus({ type: "", msg: "" });
    try {
      const data = await login(loginForm);
      setCurrentUser(data.user || null);
      setStatus({ type: "ok", msg: `Welcome ${data?.user?.username || loginForm.username}.` });
    } catch (err) {
      setCurrentUser(null);
      if (err.message === "signup_first") {
        setStatus({ type: "err", msg: "No account found. Please signup first." });
      } else if (err.message === "invalid_credentials") {
        setStatus({ type: "err", msg: "Invalid username or password." });
      } else {
        setStatus({ type: "err", msg: "Auth service unavailable." });
      }
    }
  }

  async function onSignupSubmit(e) {
    e.preventDefault();
    setStatus({ type: "", msg: "" });
    try {
      const data = await signup(signupForm);
      setCurrentUser(data.user || null);
      setStatus({ type: "ok", msg: `Signup complete for ${data?.user?.username || signupForm.username}.` });
      setAuthMode("login");
      setLoginForm({ username: signupForm.username, password: "" });
    } catch (err) {
      setCurrentUser(null);
      if (err.message === "user_already_exists") {
        setStatus({ type: "err", msg: "Username/email already exists. Try login." });
      } else {
        setStatus({ type: "err", msg: "Signup failed." });
      }
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
            <a className="btn ghost" href="#catalog" onClick={loadCatalog}>Catalogs</a>
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
            <div className="panel-metric"><span>Deploy Latency</span><strong>2m 12s</strong></div>
            <div className="panel-metric"><span>Rollback Ready</span><strong>Yes</strong></div>
          </div>
        </div>
      </header>

      <section id="login" className="split">
        <div>
          <div className="auth-switch" role="tablist" aria-label="Auth mode">
            <button className={`btn tab ${authMode === "login" ? "active" : ""}`} type="button" onClick={() => switchAuthMode("login")}>
              Login
            </button>
            <button className={`btn tab ${authMode === "signup" ? "active" : ""}`} type="button" onClick={() => switchAuthMode("signup")}>
              Sign Up
            </button>
          </div>

          <h2>{authMode === "login" ? "Login" : "Sign Up"}</h2>

          {authMode === "login" ? (
            <form className="login" onSubmit={onLoginSubmit}>
              <label>
                Username
                <input
                  value={loginForm.username}
                  onChange={(e) => setLoginForm({ ...loginForm, username: e.target.value })}
                  placeholder="cloudops"
                  required
                />
              </label>
              <label>
                Password
                <input
                  type="password"
                  value={loginForm.password}
                  onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })}
                  placeholder="your-password"
                  required
                />
              </label>
              <button className="btn primary" type="submit">Authenticate</button>
            </form>
          ) : (
            <form className="login" onSubmit={onSignupSubmit}>
              <label>
                Username
                <input
                  value={signupForm.username}
                  onChange={(e) => setSignupForm({ ...signupForm, username: e.target.value })}
                  placeholder="cloudops"
                  required
                />
              </label>
              <label>
                Email
                <input
                  type="email"
                  value={signupForm.email}
                  onChange={(e) => setSignupForm({ ...signupForm, email: e.target.value })}
                  placeholder="cloudops@example.com"
                  required
                />
              </label>
              <label>
                Password
                <input
                  type="password"
                  value={signupForm.password}
                  onChange={(e) => setSignupForm({ ...signupForm, password: e.target.value })}
                  placeholder="strong-password"
                  required
                />
              </label>
              <button className="btn primary" type="submit">Create Account</button>
            </form>
          )}

          {status.msg && <div className={`status ${status.type}`}>{status.msg}</div>}
        </div>

        <div className="side-card">
          <h3>{currentUser ? "User Data (From DB)" : "User Preview"}</h3>
          {currentUser ? (
            <div className="profile">
              {currentUser.image_url ? (
                <img className="avatar" src={currentUser.image_url} alt={currentUser.name || currentUser.username} />
              ) : (
                <div className="avatar empty-avatar">No image</div>
              )}
              <div className="profile-info">
                <h4>{currentUser.name || currentUser.username}</h4>
                <span>{currentUser.email}</span>
              </div>
              {currentUser.details && typeof currentUser.details === "object" && (
                <div className="side-list">
                  {Object.entries(currentUser.details)
                    .filter(([key]) => !["name", "full_name", "image", "image_url"].includes(key))
                    .slice(0, 4)
                    .map(([key, value]) => (
                      <span key={key}>{`${key}: ${String(value)}`}</span>
                    ))}
                </div>
              )}
            </div>
          ) : (
            <p>Login data will appear here after successful signup/login.</p>
          )}
        </div>
      </section>

      <section id="catalog" className="catalog">
        <div className="catalog-head">
          <div>
            <h2>Cloud & DevOps Catalog</h2>
            <p>Live items come from catalog-service. Refresh starts with fallback.</p>
          </div>
          <div className={`source-badge ${source === "live" ? "live" : "fallback"}`}>
            {source === "live" ? "Live microservice" : "Fallback data"}
          </div>
        </div>
        <p className="catalog-note">{catalogMsg}</p>

        {stats && (
          <div className="stats-grid">
            <div className="stat-card"><span>Total Items</span><strong>{stats.total}</strong></div>
            <div className="stat-card"><span>Core Tier</span><strong>{stats.by_tier?.core || 0}</strong></div>
            <div className="stat-card"><span>Extended Tier</span><strong>{stats.by_tier?.extended || 0}</strong></div>
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
    </div>
  );
}
