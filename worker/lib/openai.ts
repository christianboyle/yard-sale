import { OpenAIProvider, setOpenAIResponsesTransport } from "@openai/agents";

// Workers must use HTTP responses; WebSocket mode fails with "Network connection lost."
setOpenAIResponsesTransport("http");

export function isOpenRouterKey(apiKey: string): boolean {
  return apiKey.startsWith("sk-or-");
}

export function resolveModelName(model: string, apiKey: string): string {
  if (!isOpenRouterKey(apiKey) || model.includes("/")) return model;
  return `openai/${model}`;
}

export function createModelProvider(apiKey: string): OpenAIProvider {
  return new OpenAIProvider({
    apiKey,
    ...(isOpenRouterKey(apiKey) ? { baseURL: "https://openrouter.ai/api/v1" } : {}),
    useResponsesWebSocket: false,
  });
}
