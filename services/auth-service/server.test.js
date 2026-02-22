import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const checkConnectionMock = vi.fn();
const ensureUsersTableMock = vi.fn();
const hasDbConfigMock = vi.fn();
const queryMock = vi.fn();
const hashMock = vi.fn();
const compareMock = vi.fn();

vi.mock("./db.js", () => ({
  checkConnection: checkConnectionMock,
  ensureUsersTable: ensureUsersTableMock,
  hasDbConfig: hasDbConfigMock,
  query: queryMock,
}));

vi.mock("bcryptjs", () => ({
  default: {
    hash: hashMock,
    compare: compareMock,
  },
}));

const { default: app } = await import("./server.js");

describe("auth-service", () => {
  beforeEach(() => {
    checkConnectionMock.mockReset();
    ensureUsersTableMock.mockReset();
    hasDbConfigMock.mockReset();
    queryMock.mockReset();
    hashMock.mockReset();
    compareMock.mockReset();
  });

  it("returns health status", async () => {
    const res = await request(app).get("/auth/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });

  it("verifies db accessibility", async () => {
    hasDbConfigMock.mockReturnValue(true);
    checkConnectionMock.mockResolvedValue(true);

    const res = await request(app).get("/auth/db-check");

    expect(res.status).toBe(200);
    expect(res.body.ok).toBe(true);
  });

  it("creates user on signup", async () => {
    hasDbConfigMock.mockReturnValue(true);
    ensureUsersTableMock.mockResolvedValue();
    queryMock
      .mockResolvedValueOnce([])
      .mockResolvedValueOnce({ insertId: 9 });
    hashMock.mockResolvedValue("hashed-password");

    const res = await request(app).post("/auth/signup").send({
      username: "cloudops",
      email: "cloudops@example.com",
      password: "strong-password",
    });

    expect(res.status).toBe(201);
    expect(res.body.ok).toBe(true);
    expect(res.body.user.username).toBe("cloudops");
    expect(res.body.user.id).toBe(9);
    expect(res.body.user.email).toBe("cloudops@example.com");
  });

  it("returns profile on valid login payload", async () => {
    hasDbConfigMock.mockReturnValue(true);
    ensureUsersTableMock.mockResolvedValue();
    queryMock.mockResolvedValue([
      {
        id: 11,
        username: "cloudops",
        email: "cloudops@example.com",
        password_hash: "hashed-password",
        profile_json: JSON.stringify({
          name: "Cloud Ops User",
          image_url: "https://example.com/cloudops.png",
          details: { team: "platform", focus: "ecs" },
        }),
      },
    ]);
    compareMock.mockResolvedValue(true);

    const res = await request(app)
      .post("/auth/login")
      .send({ username: "cloudops", password: "secret" });

    expect(res.status).toBe(200);
    expect(res.body.ok).toBe(true);
    expect(res.body.user.username).toBe("cloudops");
    expect(res.body.user.email).toBe("cloudops@example.com");
    expect(res.body.user.name).toBe("Cloud Ops User");
    expect(res.body.user.image_url).toBe("https://example.com/cloudops.png");
    expect(res.body.user.details.team).toBe("platform");
  });

  it("returns signup_first when user does not exist", async () => {
    hasDbConfigMock.mockReturnValue(true);
    ensureUsersTableMock.mockResolvedValue();
    queryMock.mockResolvedValue([]);

    const res = await request(app)
      .post("/auth/login")
      .send({ username: "missing-user", password: "secret" });

    expect(res.status).toBe(404);
    expect(res.body.error).toBe("signup_first");
  });

  it("returns 400 when username/password missing", async () => {
    const res = await request(app).post("/auth/login").send({});
    expect(res.status).toBe(400);
  });
});
