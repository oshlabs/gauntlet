Write a GenServer `TtlStore`: an in-memory key-value store where every entry expires after a per-entry time-to-live.

API (all functions take the server as first argument, like the standard library does):

- `start_link(opts \\ [])` — starts the server; pass `opts` through to `GenServer.start_link/3` so a `:name` option works.
- `put(server, key, value, ttl_ms)` — stores `value` under `key`, replacing any existing entry (and its pending expiry). The entry expires `ttl_ms` milliseconds after this call. Returns `:ok`.
- `get(server, key)` — returns `{:ok, value}` for a live entry, `:error` for a missing or expired one.
- `delete(server, key)` — removes the entry if present, returns `:ok`.
- `size(server)` — the number of live entries.

Requirements:

- Expiry must be active: an expired entry is actually removed from state without any client having to touch the key (use timer messages, not lazy checks on read).
- Overwriting a key with a new TTL must cancel the old expiry: `put(s, :k, 1, 50); put(s, :k, 2, 10_000)` — after 100 ms the key must still be there with value 2.
- A stale expiry message for an already-deleted or already-overwritten entry must not remove the current entry or crash the server.
- The server must not accumulate one process per entry — a single GenServer holding all state.
