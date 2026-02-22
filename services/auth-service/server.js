import express from "express";
import cors from "cors";
import bcrypt from "bcryptjs";
import dotenv from "dotenv";
import { checkConnection, ensureUsersTable, hasDbConfig, query } from "./db.js";

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get("/auth/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/auth/signin", (req, res) => {
  res.send("Auth service reachable");
});

app.get("/auth/db-check", async (req, res) => {
  if (!hasDbConfig()) {
    return res.status(500).json({ ok: false, error: "db_config_missing" });
  }

  try {
    await checkConnection();
    return res.json({ ok: true, message: "database_accessible" });
  } catch {
    return res.status(500).json({ ok: false, error: "db_unreachable" });
  }
});

app.post("/auth/signup", async (req, res) => {
  const { username, email, password } = req.body || {};
  const profileJsonInput = req.body?.profile_json ?? null;

  if (!username || !email || !password) {
    return res.status(400).json({
      ok: false,
      error: "username, email and password are required",
    });
  }

  if (!hasDbConfig()) {
    return res.status(500).json({ ok: false, error: "db_config_missing" });
  }

  try {
    await ensureUsersTable();

    const existing = await query(
      "SELECT id FROM users WHERE username = ? OR email = ? LIMIT 1",
      [username, email],
    );

    if (existing.length > 0) {
      return res.status(409).json({ ok: false, error: "user_already_exists" });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    let profileJson = null;
    if (profileJsonInput !== null && profileJsonInput !== undefined) {
      if (typeof profileJsonInput === "string") {
        try {
          profileJson = JSON.stringify(JSON.parse(profileJsonInput));
        } catch {
          profileJson = null;
        }
      } else if (typeof profileJsonInput === "object") {
        profileJson = JSON.stringify(profileJsonInput);
      }
    }

    const created = await query(
      "INSERT INTO users (username, email, password_hash, profile_json) VALUES (?, ?, ?, ?)",
      [username, email, passwordHash, profileJson],
    );

    return res.status(201).json({
      ok: true,
      user: {
        id: created.insertId,
        username,
        email,
      },
    });
  } catch (err) {
  console.error("Signup error:", err);
  return res.status(500).json({
    ok: false,
    error: err.code || err.message
  });
}
});

app.post("/auth/login", async (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) {
    return res.status(400).json({ ok: false, error: "username and password required" });
  }

  if (!hasDbConfig()) {
    return res.status(500).json({ ok: false, error: "db_config_missing" });
  }

  try {
    await ensureUsersTable();

    const users = await query(
      "SELECT id, username, email, password_hash, profile_json FROM users WHERE username = ? LIMIT 1",
      [username],
    );

    if (users.length === 0) {
      return res.status(404).json({ ok: false, error: "signup_first" });
    }

    const user = users[0];

    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ ok: false, error: "invalid_credentials" });
    }

    let profile = null;
    if (user.profile_json) {
      try {
        profile =
          typeof user.profile_json === "string"
            ? JSON.parse(user.profile_json)
            : user.profile_json;
      } catch {
        profile = null;
      }
    }

    const userName = profile?.name || profile?.full_name || user.username;
    const imageUrl = profile?.image_url || profile?.image || null;
    const details =
      profile && typeof profile.details === "object" && profile.details !== null
        ? profile.details
        : profile && typeof profile === "object"
          ? profile
          : null;

    return res.json({
      ok: true,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        name: userName,
        image_url: imageUrl,
        details,
      },
    });
  } catch {
    return res.status(500).json({ ok: false, error: "login_failed" });
  }
});

if (process.env.NODE_ENV !== "test") {
  app.listen(port, () => {
    console.log(`auth-service listening on ${port}`);
  });
}

export default app;
