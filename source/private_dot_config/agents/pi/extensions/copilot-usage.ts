import {
	readStoredCredential,
	type ExtensionAPI,
	type ExtensionContext,
} from "@earendil-works/pi-coding-agent";

const PROVIDER_ID = "github-copilot";
const USAGE_URL = "https://api.github.com/copilot_internal/user";
const REFRESH_INTERVAL_MS = 5 * 60 * 1000;
const REQUEST_TIMEOUT_MS = 15_000;

type CopilotUsage = {
	login?: string;
	plan?: string;
	kind: "credits" | "premium" | "chat";
	label: string;
	used?: number;
	remaining?: number;
	limit?: number;
	overage?: number;
	resetsAt?: number;
};

type ProviderAuth = {
	auth: {
		apiKey?: string;
		headers?: Record<string, string | null>;
		baseUrl?: string;
	};
};

const authorizationToken = (headers: Record<string, string | null> | undefined): string | undefined => {
	const authorization = headers?.Authorization ?? headers?.authorization;
	const match = authorization?.match(/^Bearer\s+(.+)$/iu);
	return match?.[1];
};

const isPublicCopilotOrigin = (value: string | undefined): boolean => {
	if (!value) return false;
	try {
		const url = new URL(value);
		return url.protocol === "https:" && /^api\.[a-z0-9-]+\.githubcopilot\.com$/iu.test(url.hostname);
	} catch {
		return false;
	}
};

const finiteNumber = (value: unknown): number | undefined =>
	typeof value === "number" && Number.isFinite(value) ? value : undefined;

const objectValue = (value: unknown): Record<string, unknown> | undefined =>
	value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : undefined;

const stringValue = (value: unknown): string | undefined =>
	typeof value === "string" && value.trim() ? value.trim() : undefined;

const resetDate = (payload: Record<string, unknown>): number | undefined => {
	const value = stringValue(payload.quota_reset_date_utc)
		?? stringValue(payload.quota_reset_date)
		?? stringValue(payload.limited_user_reset_date);
	if (!value) return undefined;
	const timestamp = Date.parse(value);
	return Number.isNaN(timestamp) ? undefined : timestamp;
};

const parseUsage = (payload: Record<string, unknown>): CopilotUsage => {
	const snapshots = objectValue(payload.quota_snapshots);
	const premium = objectValue(snapshots?.premium_interactions);
	if (premium) {
		const credits = premium.token_based_billing === true;
		const limit = finiteNumber(premium.entitlement);
		const rawRemaining = finiteNumber(premium.remaining) ?? finiteNumber(premium.quota_remaining);
		if (premium.unlimited === true) {
			return {
				login: stringValue(payload.login),
				plan: stringValue(payload.copilot_plan) ?? stringValue(payload.access_type_sku),
				kind: credits ? "credits" : "premium",
				label: credits ? "AI credits" : "Premium requests",
			};
		}
		if (limit === undefined || rawRemaining === undefined) throw new Error("Copilot quota response was incomplete.");
		return {
			login: stringValue(payload.login),
			plan: stringValue(payload.copilot_plan) ?? stringValue(payload.access_type_sku),
			kind: credits ? "credits" : "premium",
			label: credits ? "AI credits" : "Premium requests",
			used: Math.max(0, finiteNumber(premium.credits_used) ?? limit - rawRemaining),
			remaining: Math.max(0, rawRemaining),
			limit,
			overage: Math.max(finiteNumber(premium.overage_count) ?? 0, -rawRemaining),
			resetsAt: resetDate(payload),
		};
	}

	const limited = objectValue(payload.limited_user_quotas);
	const monthly = objectValue(payload.monthly_quotas);
	const remaining = finiteNumber(limited?.chat);
	const limit = finiteNumber(monthly?.chat);
	if (remaining === undefined || limit === undefined) throw new Error("Copilot quota response contained no supported allowance.");
	return {
		login: stringValue(payload.login),
		plan: stringValue(payload.copilot_plan) ?? stringValue(payload.access_type_sku),
		kind: "chat",
		label: "Chat requests",
		used: Math.max(0, limit - remaining),
		remaining,
		limit,
		resetsAt: resetDate(payload),
	};
};

const formatUsage = (usage: CopilotUsage): string => {
	if (usage.limit === undefined || usage.remaining === undefined) {
		return `Copilot ${usage.kind} unlimited`;
	}
	const used = usage.used ?? Math.max(0, usage.limit - usage.remaining);
	const usedText = Math.round(used).toLocaleString();
	const limitText = Math.round(usage.limit).toLocaleString();
	const remainingText = usage.remaining.toLocaleString(undefined, { maximumFractionDigits: 1 });
	const percent = Math.round((used / usage.limit) * 100);
	const allowance = usage.kind === "credits" ? "credits" : usage.kind === "premium" ? "premium requests" : "chat requests";
	const overage = usage.overage && usage.overage > 0 ? ` · +${usage.overage} over` : "";
	return `${usedText}/${limitText} ${allowance} · ${remainingText} left · ${percent}%${overage}`;
};

const formatReport = (usage: CopilotUsage): string => [
	"GitHub Copilot usage",
	usage.login ? `Account: ${usage.login}` : undefined,
	usage.plan ? `Plan: ${usage.plan}` : undefined,
	formatUsage(usage),
].filter(Boolean).join("\n");

const fetchUsage = async (ctx: ExtensionContext, signal: AbortSignal): Promise<CopilotUsage> => {
	if (ctx.model?.provider !== PROVIDER_ID || !isPublicCopilotOrigin(ctx.model.baseUrl)) {
		throw new Error("The active model is not using the public GitHub Copilot provider.");
	}
	const registry = ctx.modelRegistry as unknown as {
		getProviderAuth(providerId: string): Promise<ProviderAuth | undefined>;
	};
	const providerAuth = await registry.getProviderAuth(PROVIDER_ID);
	if (!providerAuth?.auth.baseUrl || !isPublicCopilotOrigin(providerAuth.auth.baseUrl)) {
		throw new Error("The active Copilot authentication does not use the public provider.");
	}
	const credential = readStoredCredential(PROVIDER_ID) as Record<string, unknown> | undefined;
	const storedAccess = stringValue(credential?.access);
	const refresh = stringValue(credential?.refresh);
	if (credential?.type !== "oauth" || !storedAccess || !refresh) {
		throw new Error("Copilot usage requires an OAuth login created through Pi.");
	}
	const runtimeAccess = authorizationToken(providerAuth.auth.headers) ?? providerAuth.auth.apiKey;
	if (!runtimeAccess || runtimeAccess !== storedAccess) {
		throw new Error("The active Copilot account does not match Pi's stored OAuth account.");
	}

	const controller = new AbortController();
	const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
	const abort = () => controller.abort();
	signal.addEventListener("abort", abort, { once: true });
	try {
		const response = await fetch(USAGE_URL, {
			headers: {
				Authorization: `Bearer ${refresh}`,
				"X-GitHub-Api-Version": "2025-05-01",
				"User-Agent": "pi-copilot-usage",
			},
			signal: controller.signal,
		});
		if (!response.ok) throw new Error(`GitHub returned ${response.status} ${response.statusText}.`);
		return parseUsage(await response.json() as Record<string, unknown>);
	} finally {
		clearTimeout(timeout);
		signal.removeEventListener("abort", abort);
	}
};

export default function (pi: ExtensionAPI): void {
	let timer: ReturnType<typeof setTimeout> | undefined;
	let controller: AbortController | undefined;
	let latestUsage: CopilotUsage | undefined;

	const clearTimer = (): void => {
		if (timer) clearTimeout(timer);
		timer = undefined;
	};

	const refresh = async (ctx: ExtensionContext, showError = false): Promise<void> => {
		controller?.abort();
		controller = new AbortController();
		try {
			latestUsage = await fetchUsage(ctx, controller.signal);
			ctx.ui.setStatus("copilot-usage", formatUsage(latestUsage));
		} catch (error) {
			if (error instanceof Error && error.name === "AbortError") return;
			ctx.ui.setStatus("copilot-usage", showError ? `Copilot usage unavailable: ${error instanceof Error ? error.message : String(error)}` : undefined);
			if (showError) ctx.ui.notify(`Could not load Copilot usage: ${error instanceof Error ? error.message : String(error)}`, "warning");
		} finally {
			controller = undefined;
			clearTimer();
			timer = setTimeout(() => void refresh(ctx), REFRESH_INTERVAL_MS);
			timer.unref?.();
		}
	};

	pi.on("session_start", (_event, ctx) => void refresh(ctx));
	pi.on("model_select", (_event, ctx) => void refresh(ctx));
	pi.on("session_shutdown", () => {
		clearTimer();
		controller?.abort();
	});
	pi.registerCommand("copilot-usage", {
		description: "Show GitHub Copilot account usage",
		handler: async (_args, ctx) => {
			await refresh(ctx, true);
			if (latestUsage) ctx.ui.notify(formatReport(latestUsage), "info");
		},
	});
}
