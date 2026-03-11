# Offline Cache

The POS app now keeps two local recovery layers with `SharedPreferences`.

## Menu cache

- Successful menu/category responses are cached locally.
- If the API is temporarily unavailable, the app falls back to the last cached menu data.

## Cart recovery

- Cart items are saved after every change.
- Selected order priority is saved after every change.
- When the POS screen opens again, the in-progress cart is restored automatically.

## Limits

- This is a recovery cache, not a full offline order sync engine.
- Payments and finalized order submission still require the backend API.
