from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Catalog Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ITEMS = [
    {
        "id": "svc-001",
        "name": "Terraform State Guard",
        "type": "Infrastructure",
        "desc": "Validates remote state drift and enforces tagging policy before deploy.",
        "tier": "core",
    },
    {
        "id": "svc-002",
        "name": "ECS Cost Radar",
        "type": "FinOps",
        "desc": "Summarizes service-level cost drivers and idle capacity.",
        "tier": "core",
    },
    {
        "id": "svc-003",
        "name": "Blue-Green Orchestrator",
        "type": "Delivery",
        "desc": "Automates canary cutovers with health-aware rollbacks.",
        "tier": "core",
    },
    {
        "id": "svc-004",
        "name": "Drift Sentinel",
        "type": "Compliance",
        "desc": "Continuously verifies policy compliance across accounts.",
        "tier": "extended",
    },
    {
        "id": "svc-005",
        "name": "Pipeline SLO Watch",
        "type": "Reliability",
        "desc": "Tracks CI/CD latency and failure rate against SLOs.",
        "tier": "extended",
    },
    {
        "id": "svc-006",
        "name": "Incident Command Center",
        "type": "Operations",
        "desc": "Coordinates incident workflows, ownership, and response timelines.",
        "tier": "extended",
    },
    {
        "id": "svc-007",
        "name": "Secrets Rotation Manager",
        "type": "Security",
        "desc": "Schedules and validates zero-downtime rotation for runtime secrets.",
        "tier": "extended",
    },
    {
        "id": "svc-008",
        "name": "Workload Rightsizer",
        "type": "FinOps",
        "desc": "Recommends right-sized CPU and memory baselines from live usage trends.",
        "tier": "extended",
    },
]

@app.get("/catalog/health")
def health():
    return {"status": "ok", "service": "catalog", "version": "1.1.0"}

@app.get("/catalog/items")
def catalog_items():
    return {"items": ITEMS}

@app.get("/catalog/items/{item_id}")
def catalog_item(item_id: str):
    for item in ITEMS:
        if item["id"] == item_id:
            return item
    return {"error": "item_not_found", "id": item_id}

@app.get("/catalog/stats")
def catalog_stats():
    by_type = {}
    by_tier = {}
    for item in ITEMS:
        by_type[item["type"]] = by_type.get(item["type"], 0) + 1
        by_tier[item["tier"]] = by_tier.get(item["tier"], 0) + 1
    return {
        "total": len(ITEMS),
        "by_type": by_type,
        "by_tier": by_tier,
    }
