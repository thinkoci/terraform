const byId = (id) => document.getElementById(id);

function setStatus(ok, text) {
  const dot = byId("status-dot");
  dot.className = `status-dot ${ok ? "ok" : "error"}`;
  byId("status-text").textContent = text;
}

async function loadMessage() {
  setStatus(false, "Contacting backend...");
  byId("status-dot").className = "status-dot pending";

  try {
    const response = await fetch("/api/message", { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const payload = await response.json();
    byId("message").textContent = payload.message ?? "-";
    byId("service").textContent = payload.service ?? "-";
    byId("hostname").textContent = payload.hostname ?? "-";
    byId("server-time").textContent = payload.timestamp ?? "-";
    setStatus(true, "Backend is healthy");
  } catch (error) {
    setStatus(false, `Backend request failed: ${error.message}`);
  }
}

async function sendEcho() {
  const text = byId("echo-input").value;
  const output = byId("echo-output");
  output.textContent = "Sending...";

  try {
    const response = await fetch("/api/echo", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text }),
    });

    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.error ?? `HTTP ${response.status}`);
    }
    output.textContent = JSON.stringify(payload, null, 2);
  } catch (error) {
    output.textContent = `Request failed: ${error.message}`;
  }
}

byId("refresh").addEventListener("click", loadMessage);
byId("echo-button").addEventListener("click", sendEcho);
window.addEventListener("DOMContentLoaded", loadMessage);
