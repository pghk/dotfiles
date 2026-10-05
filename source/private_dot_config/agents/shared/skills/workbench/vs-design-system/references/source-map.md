# Story title → source file map

All paths are relative to the canonical clone:

```text
~/Projects/us-suite-design-system/
```

| Storybook title | Source file |
|---|---|
| Design System/Brand/Logos | `stories/Logos.stories.js` |
| Design System/Components/Accordion | `stories/Accordion.stories.js` |
| Design System/Components/Alerts | `stories/Alerts.stories.js` |
| Design System/Components/Avatar | `stories/Avatar.stories.js` |
| Design System/Components/Badge | `stories/Badge.stories.js` |
| Design System/Components/Breadcrumbs | `stories/Breadcrumbs.stories.js` |
| Design System/Components/Buttons/Primary | `stories/Button.stories.js` |
| Design System/Components/Buttons/Secondary | `stories/SecondaryButton.stories.js` |
| Design System/Components/Buttons/Split Button | `stories/SplitButton.stories.js` |
| Design System/Components/Cards | `stories/Cards.stories.js` |
| Design System/Components/Cards/Dashboard Cards | `stories/DashboardCards.stories.js` |
| Design System/Components/Chips | `stories/Chips.stories.js` |
| Design System/Components/Controls | `stories/Controls.stories.js` |
| Design System/Components/Date Picker | `stories/DatePicker.stories.js` |
| Design System/Components/Dropdown | `stories/Dropdown.stories.js` |
| Design System/Components/Headers | `stories/Headers.stories.js` |
| Design System/Components/Headers/Brand Headers | `stories/BrandHeaders.stories.js` |
| Design System/Components/Input | `stories/Input.stories.js` |
| Design System/Components/Input Groups | `stories/InputGroups.stories.js` |
| Design System/Components/Modal | `stories/Modal.stories.js` |
| Design System/Components/Multi-Select | `stories/MultiSelect.stories.js` |
| Design System/Components/Pagination | `stories/Pagination.stories.js` |
| Design System/Components/Progress Bar | `stories/ProgressBar.stories.js` |
| Design System/Components/Table | `stories/Table.stories.js` |
| Design System/Components/Tabs | `stories/Tabs.stories.js` |
| Design System/Components/Textarea | `stories/Textarea.stories.js` |
| Design System/Components/Toast | `stories/Toast.stories.js` |
| Design System/Components/Toggle | `stories/Toggle.stories.js` |
| Design System/Design Tokens/Colours | `stories/PrimitiveColours.stories.js` |
| Design System/Design Tokens/Integration Guide | `stories/TokenIntegration.stories.js` |
| Design System/Design Tokens/Semantic Tokens | `stories/SemanticColours.stories.js` |
| Design System/Design Tokens/Sizing | `stories/Sizing.stories.js` |
| Design System/Foundation/Typography | `stories/Typography.stories.js` |
| Patterns/Library | `stories/Patterns.stories.js` |
| Prototypes/Ravenna/Admissions | `stories/Admissions.stories.js` |

Regenerate from the clone:

```bash
cd ~/Projects/us-suite-design-system/stories
for file in *.stories.js; do
  title=$(grep -m1 "title:" "$file" | sed -E "s/.*title:\s*['\"](.*)['\"].*/\1/")
  [ -n "$title" ] && echo "| $title | stories/$file |"
done | sort
```
