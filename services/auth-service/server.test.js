import request from "supertest";
import { describe, expect, it } from "vitest";
import app from "./server.js";

describe("auth-service", () => {
  it("returns health status", async () => {
    const res = await request(app).get("/auth/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });

  it("returns token on valid login payload", async () => {
    const res = await request(app)
      .post("/auth/login")
      .send({ username: "cloudops", password: "secret" });

    expect(res.status).toBe(200);
    expect(res.body.user.username).toBe("cloudops");
    expect(typeof res.body.token).toBe("string");
  });

  it("returns 400 when username/password missing", async () => {
    const res = await request(app).post("/auth/login").send({});
    expect(res.status).toBe(400);
  });
});
