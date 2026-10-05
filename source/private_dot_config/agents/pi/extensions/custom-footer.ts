import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const formatTokens = (tokens: number): string => {
	if (tokens < 1_000) return `${tokens}`;
	if (tokens < 1_000_000) return `${(tokens / 1_000).toFixed(1)}k`;
	return `${(tokens / 1_000_000).toFixed(1)}M`;
};

const formatPath = (path: string): string => {
	const home = process.env.HOME ?? process.env.USERPROFILE;
	return home && (path === home || path.startsWith(`${home}/`))
		? `~${path.slice(home.length)}`
		: path;
};

const usageTotals = (ctx: ExtensionContext) => {
	const totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
	let latestCacheHitRate: number | undefined;

	for (const entry of ctx.sessionManager.getEntries()) {
		const usage = entry.type === "message" && entry.message.role === "assistant"
			? entry.message.usage
			: entry.type === "message" && entry.message.role === "toolResult"
				? entry.message.usage
				: entry.type === "branch_summary" || entry.type === "compaction"
					? entry.usage
					: undefined;
		if (!usage) continue;

		totals.input += usage.input;
		totals.output += usage.output;
		totals.cacheRead += usage.cacheRead;
		totals.cacheWrite += usage.cacheWrite;
		totals.cost += usage.cost.total;
		if (entry.type === "message" && entry.message.role === "assistant") {
			const promptTokens = usage.input + usage.cacheRead + usage.cacheWrite;
			latestCacheHitRate = promptTokens > 0 ? (usage.cacheRead / promptTokens) * 100 : undefined;
		}
	}

	return { totals, latestCacheHitRate };
};

const align = (left: string, right: string, width: number): string => {
	const available = width - visibleWidth(left) - visibleWidth(right);
	if (available >= 2) return `${left}${" ".repeat(available)}${right}`;
	if (visibleWidth(left) >= width) return truncateToWidth(left, width, "...");
	return `${truncateToWidth(left, width - visibleWidth(right) - 2, "...")}${" ".repeat(2)}${truncateToWidth(right, width, "")}`;
};

type FooterMode = "full" | "compact";

const renderFooter = (
	ctx: ExtensionContext,
	theme: any,
	footerData: any,
	width: number,
	mode: FooterMode,
): string[] => {
	const branch = footerData.getGitBranch();
	const sessionName = ctx.sessionManager.getSessionName();
	let path = formatPath(ctx.cwd);
	if (branch) path += ` (${branch})`;
	if (sessionName) path += ` · ${sessionName}`;

	const context = ctx.getContextUsage();
	const contextWindow = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
	const contextText = context?.percent === null || context?.percent === undefined
		? `?/${formatTokens(contextWindow)}`
		: `${context.percent.toFixed(1)}%/${formatTokens(contextWindow)}`;
	const model = ctx.model?.id ?? "no-model";
	const thinking = ctx.model?.reasoning ? ` · ${ctx.thinkingLevel || "off"}` : "";
	const modelText = `${model}${thinking} · ${contextText}`;

	if (mode === "compact") {
		return [align(theme.fg("dim", path), theme.fg("dim", modelText), width)];
	}

	const { totals, latestCacheHitRate } = usageTotals(ctx);
	const cost = `$${totals.cost.toFixed(3)}`;
	const tokens = `↑${formatTokens(totals.input)} ↓${formatTokens(totals.output)}`;
	const cache = [
		totals.cacheRead ? `R${formatTokens(totals.cacheRead)}` : undefined,
		totals.cacheWrite ? `W${formatTokens(totals.cacheWrite)}` : undefined,
		latestCacheHitRate === undefined ? undefined : `CH${latestCacheHitRate.toFixed(1)}%`,
	].filter(Boolean).join(" ");
	const statuses = [...footerData.getExtensionStatuses().values()].join(" ");
	const bottomLeft = [tokens, cost, cache].filter(Boolean).join(" · ");

	return [
		align(theme.fg("dim", path), theme.fg("dim", statuses), width),
		align(theme.fg("dim", bottomLeft), theme.fg("dim", modelText), width),
	];
};

const setFooter = (ctx: ExtensionContext, mode: FooterMode): void => {
	ctx.ui.setFooter((tui, theme, footerData) => {
		const unsubscribe = footerData.onBranchChange(() => tui.requestRender());
		return {
			dispose: unsubscribe,
			invalidate() {},
			render: (width: number) => renderFooter(ctx, theme, footerData, width, mode),
		};
	});
};

export default function (pi: ExtensionAPI): void {
	let mode: FooterMode = "full";

	pi.on("session_start", (_event, ctx) => {
		setFooter(ctx, mode);
	});

	pi.registerCommand("footer", {
		description: "Set the footer display: compact or full",
		handler: async (args, ctx) => {
			const requestedMode = args.trim();
			if (requestedMode !== "compact" && requestedMode !== "full") {
				ctx.ui.notify("Usage: /footer <compact|full>", "error");
				return;
			}

			mode = requestedMode;
			setFooter(ctx, mode);
			ctx.ui.notify(`Footer set to ${mode} view`, "info");
		},
	});
}
