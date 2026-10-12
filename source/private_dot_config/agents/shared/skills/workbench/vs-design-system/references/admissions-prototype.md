# Ravenna Admissions prototype: page map

The Storybook story `Prototypes/Ravenna/Admissions` (`stories/Admissions.stories.js`)
is the parent-facing Ravenna Core prototype. `ravenna-suite/core/build.mjs`
renders it to `ravenna-suite/core/index.html`, a standalone file that opens
without a server. Rebuilding only changes the date picker's "today"; restore
the file with `git checkout` after a rebuild.

## Page model

The story is a single document. Each page is a `<div class="rv-page" id="adm-page-<id>">`;
`admNav('<id>')` shows one and hides the rest. Locate a page's markup with:

```bash
grep -n 'id="adm-page-<id>"' ~/Projects/us-suite-design-system/stories/Admissions.stories.js
```

The story file is ~750 KB: read a page by line range from that match, never whole.

## Pages

| id | Heading | Reach it by |
|---|---|---|
| `landing` | Start here, go anywhere. | initial page |
| `login` | Continue with | `admNav`; `admAuthShowView('register' \| 'signin')` |
| `onboarding` | Let's get set up | `admNav` |
| `household` | Household & Guardian Details | `admNav` |
| `children` | Add Your Children | `admNav` |
| `review` | Review Your Details | `admNav` |
| `search-results` | (search form) | `admNavSearchResults('<query>')` |
| `dashboard` | Welcome back, Danny | `admNav` |
| `child-profile` | Student Profile | `admNav`; `admCpShowSection('profile' \| 'education' \| 'guardians' \| 'households' \| 'siblings')` |
| `account` | Account Details | `admNav` |
| `applications` | Applications | `admNav`, or dashboard "View all applications" |
| `school` | (school name) | Click `.rv-apb-school` in an application card on `dashboard` or `applications` |
| `school-directory` | (school name) | Click a school in `search-results` |
| `apply-school` | Let's start your application | Apply to School from `school-directory` |
| `apply-type`, `apply-student`, `apply-additional`, `apply-review` | Apply-to-school steps | Cards on `apply-school` |

`school`, `school-directory`, and `apply-school` are populated from the clicked
card's data; `admNav` alone shows them with placeholder or stale content.

`school` is the Student Application page: breadcrumb header, Preliminary and
Additional Steps pill tabs (`#rv-tab-prelim`, `#rv-tab-additional`) over step
accordions, and a sidebar of alerts and an Application Steps summary.

## Rendering

`https://design.venturedsolutions.com/` requires Entra ID sign-in, so neither
`web_fetch` nor `curl` can reach it; give the user the Storybook path to view
it themselves. Render pages yourself with the bundled script, run from a
checkout that has `playwright` in `node_modules` (Hub does):

```bash
cd ~/local/hub/dev
node ~/.copilot/skills/shared/workbench/vs-design-system/scripts/render-prototype.mjs \
  --page dashboard --click '#adm-page-dashboard .rv-apb-school' --click '#rv-tab-additional'
```

It prints the active page id and screenshot path; view the PNG. Run `--help` for
the remaining options (`--eval`, `--out`, `--width`, `--viewport`).
