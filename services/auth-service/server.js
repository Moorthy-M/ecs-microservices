import express from "express";
import cors from "cors";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const secret = process.env.JWT_SECRET || "secret";

app.use(cors());
app.use(express.json());

app.get("/auth/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/auth/signin", (req, res) => {
  res.send("Auth service reachable");
});

app.post("/auth/login", (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) {
    return res.status(400).json({ error: "username and password required" });
  }

  const token = jwt.sign({ sub: username }, secret, { expiresIn: "15m" });
  return res.json({ token, user: { username } });
});

if (process.env.NODE_ENV !== "test") {
  app.listen(port, () => {
    console.log(`auth-service listening on ${port}`);
  });
}

export default app;
