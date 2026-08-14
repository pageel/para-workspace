---
id: PAYMENT-PRICE-TAMPERING
severity_max: CRITICAL
applies_to: typescript, javascript, python, go, php, dotnet
---

# Payment Price Tampering & Unverified Webhooks

## Intent

Detects security flaws in third-party payment gateway integrations (Stripe, PayPal, Razorpay, Square). Common vulnerabilities include trusting client-supplied order amounts (`req.body.amount`, `req.body.price`) during checkout initialization, or failing to cryptographically verify incoming payment webhook signatures (`stripe.webhooks.constructEvent`, HMAC signatures). Attackers tamper with request payloads to purchase items for $0.01 or forge success webhooks without paying.

Reference OWASP Cheat Sheet Series: `Third_Party_Payment_Gateway_Integration_Cheat_Sheet.md`.

## When CRITICAL

- Payment checkout endpoint accepts transaction `amount` directly from client request body without recalculating from database price records.
- Payment Webhook handler processes payment fulfillment without verifying the gateway's cryptographic signature header.

## When HIGH / MEDIUM

- Hardcoded secret keys used for webhook signature verification.

## Search patterns (suggestions)

```typescript
stripe.paymentIntents.create\(
webhooks.constructEvent\(
stripe-signature
req.body.amount
```

## Examples

### BAD — Price Tampering & Missing Webhook Verification
```typescript
// BAD: Client controls the payment amount! Attacker sends amount: 1
export async function createCheckout(req: Request) {
  const { productId, amount } = await req.json(); // UNTRUSTED amount!
  const session = await stripe.checkout.sessions.create({
    line_items: [{ price_data: { unit_amount: amount }, quantity: 1 }]
  });
  return Response.json({ url: session.url });
}

// BAD: Webhook trusts incoming payload without signature check!
export async function handleWebhook(req: Request) {
  const event = await req.json(); // Unverified event payload!
  if (event.type === "payment_intent.succeeded") {
    await fulfillOrder(event.data.object.metadata.orderId);
  }
}
```

### GOOD — Server-Side Price Calculation & Webhook Signature Verification
```typescript
// GOOD: Amount is fetched from authoritative DB; Webhook signature is verified
export async function createCheckout(req: Request, db: Database, env: Env) {
  const { productId } = await req.json();
  const product = await db.getProduct(productId); // Server-side price query
  
  const session = await stripe.checkout.sessions.create({
    line_items: [{ price_data: { unit_amount: product.priceInCents }, quantity: 1 }]
  });
  return Response.json({ url: session.url });
}

export async function handleWebhook(req: Request, env: Env) {
  const sig = req.headers.get("stripe-signature");
  const rawBody = await req.text();
  
  // Verify HMAC signature using Webhook Secret
  const event = stripe.webhooks.constructEvent(rawBody, sig, env.STRIPE_WEBHOOK_SECRET);
  if (event.type === "payment_intent.succeeded") {
    await fulfillOrder(event.data.object.metadata.orderId);
  }
}
```

## Fix recommendation

1. Always calculate total transaction amounts on the backend by fetching authoritative product prices from the database.
2. Verify cryptographic signatures (e.g. `stripe-signature` via HMAC SHA256) on all payment notification webhooks before fulfilling orders.
