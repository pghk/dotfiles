import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import {
	Container,
	Input,
	Key,
	SelectList,
	Text,
	fuzzyFilter,
	matchesKey,
	type SelectItem,
} from "@earendil-works/pi-tui";

const formatRate = (rate: number): string => `$${rate.toFixed(2)}/M`;

const formatCost = (model: any): string => {
	const { input, output, cacheRead, cacheWrite } = model.cost;
	return `in ${formatRate(input)} · out ${formatRate(output)} · cache read ${formatRate(cacheRead)} · cache write ${formatRate(cacheWrite)}`;
};

const formatContextWindow = (tokens: number): string => {
	if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(1)}M`;
	return `${Math.round(tokens / 1_000)}K`;
};

const modelDetails = (model: any): string => {
	const capabilities = [
		model.reasoning ? "reasoning" : undefined,
		model.input.includes("image") ? "images" : undefined,
	].filter(Boolean).join(" · ");
	const capabilityText = capabilities ? ` · ${capabilities}` : "";
	return [
		`${model.id} [${model.provider}]`,
		formatCost(model),
		`context ${formatContextWindow(model.contextWindow)} · max output ${formatContextWindow(model.maxTokens)}${capabilityText}`,
	].filter(Boolean).join("\n");
};

const modelItems = (models: readonly any[]): SelectItem[] => models.map((model) => ({
	value: `${model.provider}/${model.id} ${model.name}`.toLowerCase(),
	label: model.name || model.id,
	description: formatCost(model),
}));

const showModelPicker = async (pi: ExtensionAPI, ctx: any): Promise<void> => {
	const scopedModels = ctx.scopedModels ?? [];
	const models = (scopedModels.length > 0
		? scopedModels.map((entry: any) => entry.model)
		: ctx.modelRegistry.getAvailable()) as readonly any[];
	const items = modelItems(models);
	const modelBySearchValue = new Map(models.map((model) => [
		`${model.provider}/${model.id} ${model.name}`.toLowerCase(),
		model,
	]));

	if (items.length === 0) {
		ctx.ui.notify("No configured models are available.", "warning");
		return;
	}

	const selectedModel = await ctx.ui.custom<any>((tui: any, theme: any, _keybindings: any, done: (model: any) => void) => {
		const container = new Container();
		const searchInput = new Input();
		const selectionDetails = new Text("", 1, 0);
		const listContainer = new Container();
		let list: SelectList;

		const updateDetails = (item: SelectItem | null): void => {
			const model = item ? modelBySearchValue.get(item.value) : undefined;
			selectionDetails.setText(model ? theme.fg("muted", modelDetails(model)) : "");
			tui.requestRender();
		};

		const createList = (filteredModels: readonly any[]): SelectList => {
			const filteredItems = modelItems(filteredModels);
			const nextList = new SelectList(filteredItems, Math.min(filteredItems.length, 10), {
				selectedPrefix: (text: string) => theme.fg("accent", text),
				selectedText: (text: string) => theme.fg("accent", text),
				description: (text: string) => theme.fg("muted", text),
				scrollInfo: (text: string) => theme.fg("dim", text),
				noMatch: (text: string) => theme.fg("warning", text),
			});
			nextList.onSelect = (item): void => done(modelBySearchValue.get(item.value));
			nextList.onCancel = (): void => done(null);
			nextList.onSelectionChange = updateDetails;
			return nextList;
		};

		list = createList(models);
		listContainer.addChild(list);
		searchInput.onSubmit = (): void => {
			const item = list.getSelectedItem();
			if (item) done(modelBySearchValue.get(item.value));
		};

		const initialItem = list.getSelectedItem();
		updateDetails(initialItem);
		container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));
		container.addChild(new Text(theme.fg("accent", theme.bold("Select model with pricing")), 1, 0));
		container.addChild(new Text(theme.fg("dim", "Type to search · Enter to select · Esc to cancel"), 1, 0));
		container.addChild(searchInput);
		container.addChild(listContainer);
		container.addChild(selectionDetails);
		container.addChild(new DynamicBorder((text: string) => theme.fg("accent", text)));

		return {
			render: (width: number) => container.render(width),
			invalidate: () => container.invalidate(),
			handleInput: (data: string) => {
				if (matchesKey(data, Key.up) || matchesKey(data, Key.down) || matchesKey(data, Key.enter) || matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c"))) {
					list.handleInput(data);
					return;
				}
				searchInput.handleInput(data);
				const query = searchInput.getValue().trim();
				const filteredModels = query
					? fuzzyFilter([...models], query, (model) => `${model.name} ${model.id} ${model.provider}`)
					: models;
				listContainer.clear();
				list = createList(filteredModels);
				listContainer.addChild(list);
				updateDetails(list.getSelectedItem());
			},
		};
	});

	if (!selectedModel) return;
	if (await pi.setModel(selectedModel)) {
		ctx.ui.notify(`Selected ${selectedModel.provider}/${selectedModel.id}`, "info");
	} else {
		ctx.ui.notify(`No API key is available for ${selectedModel.provider}/${selectedModel.id}`, "error");
	}
};

export default function (pi: ExtensionAPI): void {
	pi.registerCommand("models", {
		description: "Select a model with pricing and capability details",
		handler: async (_args, ctx) => showModelPicker(pi, ctx),
	});
}
