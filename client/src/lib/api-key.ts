const KEY = "wacalls.apiKey";

export const getApiKey = (): string => {
  const injected = (globalThis as unknown as { __WACALLS_API_KEY__?: string }).__WACALLS_API_KEY__;
  if (typeof injected === "string" && injected) return injected;
  try {
    return localStorage.getItem(KEY) ?? "";
  } catch {
    return "";
  }
};

export const setApiKey = (k: string): void => {
  try {
    if (k) localStorage.setItem(KEY, k);
    else localStorage.removeItem(KEY);
  } catch {}
};
