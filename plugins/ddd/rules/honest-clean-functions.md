---
title: Honest Functions — Signatures Must Reflect All Outcomes
paths:
  - "src/**/*"
impact: HIGH
---

# Honest Functions — Signatures Must Reflect All Outcomes

A function is "honest" when its type signature tells the complete story: what it accepts, what it returns, and what can go wrong. A dishonest function hides failure modes behind a clean return type, forcing callers to discover thrown exceptions, silent nulls, or mutated state only by reading the implementation. This defeats static analysis and makes call sites fragile — the compiler cannot enforce handling of outcomes that the type system does not express.

Encode all possible outcomes in the return type. Use discriminated unions or Result types to represent success and failure paths explicitly. When a function can fail, the caller must see that possibility in the type signature, not in a `throw` buried inside the body. Reserve exceptions for truly exceptional and for expected domain outcomes like "not found" or "validation failed." A function whose signature the caller can trust without reading its body is one that composes safely, tests cleanly, and refactors without surprises.

## Incorrect

The return type promises `UserProfile`, but the function secretly throws on expected domain conditions and mutates an external cache. The caller has no compile-time signal that failure is possible or that side effects occur.

```typescript
// user-profile-service.ts — dishonest signature hides failure and side effects
const profileCache = new Map<string, UserProfile>();

async function getUserProfile(userId: string): Promise<UserProfile> {
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new Error("User not found"); // caller cannot see this from the type
  }
  if (user.isSuspended) {
    throw new Error("Account suspended"); // another hidden failure path
  }

  // Hidden mutation: populates an external cache
  profileCache.set(userId, { id: user.id, name: user.name, email: user.email });

  return { id: user.id, name: user.name, email: user.email };
}
```

## Correct

The return type is a discriminated union that makes every outcome visible. The caller must handle both success and failure at compile time. No hidden throws, no secret mutations.

```typescript
// user-profile-service.ts — honest signature encodes all outcomes
type GetProfileResult =
  | { ok: true; profile: UserProfile }
  | { ok: false; error: "not_found" | "suspended" };

async function getUserProfile(userId: string): Promise<GetProfileResult> {
  const user = await userRepository.findById(userId);
  if (!user) {
    return { ok: false, error: "not_found" };
  }
  if (user.isSuspended) {
    return { ok: false, error: "suspended" };
  }
  return { ok: true, profile: { id: user.id, name: user.name, email: user.email } };
}

// call site — compiler enforces handling of both paths
const result = await getUserProfile(userId);
if (!result.ok) {
  logger.warn("Cannot load profile", { userId, reason: result.error });
  return;
}
renderProfile(result.profile);
```

## Reference

- [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) — Alexis King
- [Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/) — Scott Wlaschin
- [Making Impossible States Impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8) — Richard Feldman
