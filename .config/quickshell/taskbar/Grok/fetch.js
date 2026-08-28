const fs = require("fs");
const os = require("os");
const path = require("path");

const DEFAULT_CLIENT_ID = "b1a00492-073a-47ea-816f-4c329264a828";
const DEFAULT_ISSUER = "https://auth.x.ai";
const BILLING_URL = "https://cli-chat-proxy.grok.com/v1/billing?format=credits";

function fail(msg) {
  process.stdout.write(JSON.stringify({ error: msg }));
}

function collectEntries(node, parentKey = null, out = []) {
  if (!node || typeof node !== "object") return out;
  if (typeof node.key === "string" && node.key.length > 0) {
    out.push({ parentKey, entry: node });
  }
  if (Array.isArray(node)) {
    for (const item of node) collectEntries(item, parentKey, out);
    return out;
  }
  for (const [k, v] of Object.entries(node)) collectEntries(v, k, out);
  return out;
}

function score(item) {
  const e = item.entry;
  const mode = String(e.auth_mode || "");
  let s = 0;
  if (e.refresh_token) s += 4;
  if (mode === "oidc" || mode === "grok" || mode === "web_login") s += 3;
  if (mode === "api_key") s -= 8;
  if (String(e.oidc_issuer || item.parentKey || "").includes("auth.x.ai"))
    s += 2;
  return s;
}

function isExpired(entry, skewSec = 60) {
  const raw = entry.expires_at;
  if (!raw) return false;
  const t = Date.parse(raw);
  if (Number.isNaN(t)) return false;
  return Date.now() >= t - skewSec * 1000;
}

function writeAuth(authPath, root) {
  const tmp = authPath + ".tmp";
  fs.writeFileSync(tmp, JSON.stringify(root, null, 2) + "\n", { mode: 0o600 });
  fs.renameSync(tmp, authPath);
}

async function discoverTokenUrl(issuer) {
  const base = (issuer || DEFAULT_ISSUER).replace(/\/$/, "");
  try {
    const res = await fetch(`${base}/.well-known/openid-configuration`);
    if (!res.ok) return `${base}/oauth2/token`;
    const d = await res.json();
    return d.token_endpoint || `${base}/oauth2/token`;
  } catch {
    return `${base}/oauth2/token`;
  }
}

async function refreshAccess(entry) {
  const clientId = entry.oidc_client_id || DEFAULT_CLIENT_ID;
  const tokenUrl = await discoverTokenUrl(entry.oidc_issuer || DEFAULT_ISSUER);
  const body = new URLSearchParams({
    grant_type: "refresh_token",
    refresh_token: entry.refresh_token,
    client_id: clientId,
  });
  if (entry.principal_type)
    body.set("principal_type", String(entry.principal_type));
  if (entry.principal_id) body.set("principal_id", String(entry.principal_id));

  const res = await fetch(tokenUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      Accept: "application/json",
    },
    body,
  });
  const text = await res.text();
  let json = {};
  try {
    json = JSON.parse(text);
  } catch {}
  if (!res.ok || !json.access_token) {
    const desc = json.error_description || json.error || `HTTP ${res.status}`;
    throw new Error(`refresh failed: ${desc}`);
  }
  return json;
}

async function billing(token) {
  return fetch(BILLING_URL, {
    headers: {
      Authorization: `Bearer ${token}`,
      "X-XAI-Token-Auth": "xai-grok-cli",
      Accept: "application/json",
    },
  });
}

const authPath = path.join(os.homedir(), ".grok", "auth.json");
if (!fs.existsSync(authPath)) {
  fail("no ~/.grok/auth.json — run grok login");
  process.exit(0);
}

let root;
try {
  root = JSON.parse(fs.readFileSync(authPath, "utf8"));
} catch {
  fail("could not read auth.json");
  process.exit(0);
}

const items = collectEntries(root);
const picked = items.sort((a, b) => score(b) - score(a))[0];
if (!picked) {
  fail("could not parse token from auth.json");
  process.exit(0);
}

const { parentKey, entry } = picked;
let token = entry.key || entry.access_token || entry.token;

try {
  if (entry.refresh_token && isExpired(entry)) {
    const tokens = await refreshAccess(entry);
    token = tokens.access_token;
    entry.key = tokens.access_token;
    if (tokens.refresh_token) entry.refresh_token = tokens.refresh_token;
    if (tokens.expires_in) {
      entry.expires_at = new Date(
        Date.now() + tokens.expires_in * 1000,
      ).toISOString();
    }
    if (parentKey && root[parentKey]) root[parentKey] = entry;
    writeAuth(authPath, root);
  }

  let res = await billing(token);

  if ((res.status === 401 || res.status === 403) && entry.refresh_token) {
    const tokens = await refreshAccess(entry);
    token = tokens.access_token;
    entry.key = tokens.access_token;
    if (tokens.refresh_token) entry.refresh_token = tokens.refresh_token;
    if (tokens.expires_in) {
      entry.expires_at = new Date(
        Date.now() + tokens.expires_in * 1000,
      ).toISOString();
    }
    if (parentKey && root[parentKey]) root[parentKey] = entry;
    writeAuth(authPath, root);
    res = await billing(token);
  }

  const body = await res.text();
  if (!res.ok) {
    fail(`HTTP ${res.status} after refresh — run grok login`);
    process.exit(0);
  }
  process.stdout.write(body);
} catch (e) {
  fail(String(e.message || e));
}
