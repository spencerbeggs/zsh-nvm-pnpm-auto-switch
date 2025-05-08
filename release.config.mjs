import { execSync } from "child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Get repository URL from package.json
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const packageJsonPath = path.join(__dirname, "package.json");
const packageJsonContent = fs.readFileSync(packageJsonPath, "utf8");
const packageJson = JSON.parse(packageJsonContent);
const repositoryUrl = packageJson?.repository?.url ?? "https://github.com/spencerbeggs/zsh-nvm-pnpm-auto-switch.git";

function getDryRunConfig() {
	return {
		repositoryUrl: getLocalRepoUrl(),
		branches: getCurrentBranch(),
		plugins: [
			[
				"@semantic-release/commit-analyzer",
				{
					preset: "conventionalcommits",
					releaseRules: [
						{ type: "feat", release: "minor" },
						{ type: "fix", release: "patch" },
						{ type: "perf", release: "patch" },
						{ type: "build", release: "patch" },
						{ type: "ci", release: "patch" },
						{ type: "chore", release: "patch" },
						{ type: "docs", release: "patch" },
						{ type: "refactor", release: "patch" },
						{ type: "style", release: "patch" },
						{ type: "test", release: "patch" },
						{ scope: "no-release", release: false },
						{ breaking: true, release: "major" },
						// Explicitly handle the feat! syntax
						{ type: "feat!", release: "major" },
						{ type: "fix!", release: "major" },
						{ type: "perf!", release: "major" },
						{ type: "build!", release: "major" },
						{ type: "ci!", release: "major" },
						{ type: "chore!", release: "major" },
						{ type: "docs!", release: "major" },
						{ type: "refactor!", release: "major" },
						{ type: "style!", release: "major" },
						{ type: "test!", release: "major" }
					],
					parserOpts: {
						noteKeywords: ["BREAKING CHANGE", "BREAKING CHANGES"],
						headerPattern: /^(\w*)(?:\(([\w\$\.\-\* ]*)\))?(!)?:(.*)$/,
						breakingHeaderPattern: /^(\w*)(?:\(([\w\$\.\-\* ]*)\))?!:(.*)$/
					}
				}
			],
			[
				"@semantic-release/release-notes-generator",
				{
					preset: "conventionalcommits",
					parserOpts: {
						noteKeywords: ["BREAKING CHANGE", "BREAKING CHANGES"],
						issuePrefixes: ["#"]
					},
					writerOpts: {
						// Partial templates
						commitPartial: "- {{#if scope}}**{{scope}}:** {{/if}}{{subject}} ({{hash}})\n",
						notePartial: "- {{text}}\n",

						// Group commits by their type
						groupBy: "type",

						// Sort commits within groups
						commitsSort: ["subject", "scope"],

						// Sort note groups (BREAKING CHANGE should be first)
						noteGroupsSort: (a, b) => {
							// Always put BREAKING CHANGE at the top
							if (a.title.includes("BREAKING CHANGE") || a.title === "🚨 Breaking Changes") return -1;
							if (b.title.includes("BREAKING CHANGE") || b.title === "🚨 Breaking Changes") return 1;

							// Default alphabetical sort for other note types
							return a.title.localeCompare(b.title);
						},

						// Customize the header to include version and date
						headerPartial: "## {{version}} {{#if date}}({{date}}){{/if}}\n\n",

						// Custom main template that puts note groups before commit groups
						mainTemplate:
							"{{> header}}{{#if noteGroups}}{{#each noteGroups}}\n\n### {{title}}\n\n{{#each notes}}* {{text}}\n{{/each}}{{/each}}{{/if}}{{#if commitGroups}}{{#each commitGroups}}\n\n### {{title}}\n\n{{#each commits}}{{> commit root=@root}}{{/each}}{{/each}}{{/if}}\n",

						// Sort sections in a specific order
						commitGroupsSort: (a, b) => {
							// Define section order
							const order = [
								"🚨 Breaking Changes",
								"✨ Features",
								"🐛 Bug Fixes",
								"🧪 Tests",
								"📦 Code Refactoring",
								"⚡ Performance Improvements",
								"💎 Styles",
								"📚 Documentation",
								"⚙️ Continuous Integration",
								"🛠️ Build System",
								"♻️ Chores",
								"🗑 Reverts"
							];
							const indexA = order.indexOf(a.title);
							const indexB = order.indexOf(b.title);

							// Sort based on the order
							if (indexA !== -1 && indexB !== -1) {
								return indexA - indexB;
							}

							// Prioritize sections in the list
							if (indexA !== -1) return -1;
							if (indexB !== -1) return 1;

							// Fallback to alphabetical sort
							return a.title.localeCompare(b.title);
						},

						// Transform function for commits
						transform: (commit, context) => {
							// Skip certain commits
							if (commit.subject?.toLowerCase().startsWith("initial commit") || !commit.type) {
								return false;
							}

							// Create a new object that will contain all the properties of the original commit
							const result = { ...commit };

							// Ensure shortHash is available for URL links
							if (result.hash) {
								result.shortHash = result.hash.substring(0, 7);
							}

							// Process issue references
							if (typeof result.subject === "string") {
								const issues = [];
								result.subject = result.subject.replace(/#([0-9]+)/g, (_, issue) => {
									issues.push(issue);
									const issueUrl = context.repository
										? `${context.host ?? ""}/${context.owner ?? ""}/${context.repository}`
										: (context.repoUrl ?? "");
									return `[#${issue}](${issueUrl ? `${issueUrl}/issues/${issue}` : `#${issue}`})`;
								});
							}

							// Add emoji based on type
							const types = {
								breaking: "🚨 Breaking Changes",
								feat: "✨ Features",
								fix: "🐛 Bug Fixes",
								docs: "📚 Documentation",
								style: "💎 Styles",
								refactor: "📦 Code Refactoring",
								perf: "⚡ Performance Improvements",
								test: "🧪 Tests",
								build: "🛠️ Build System",
								ci: "⚙️ Continuous Integration",
								chore: "♻️ Chores",
								revert: "🗑 Reverts"
							};

							// Handle types with ! in them
							let typeKey = result.type;
							if (typeKey && typeKey.endsWith("!")) {
								// Remove the ! to match the type in the types object
								typeKey = typeKey.substring(0, typeKey.length - 1);
							}

							// Override type with emoji version
							if (typeKey && types[typeKey]) {
								result.type = types[typeKey];
							}

							console.log("result", result);

							// Handle BREAKING CHANGE notes
							if (result.notes) {
								// Create a new array with modified note objects
								result.notes = result.notes.map((note) => {
									// Clone the note object
									const modifiedNote = { ...note };
									// Rename the title from "BREAKING CHANGE" to "🚨 Breaking Changes"
									if (
										modifiedNote.title === "BREAKING CHANGE" ||
										modifiedNote.title === "BREAKING CHANGES"
									) {
										modifiedNote.title = "🚨 Breaking Changes";
									}
									return modifiedNote;
								});
							}

							// Handle the feat! syntax - create a breaking change note if there isn't one already
							if (commit.type && commit.type.endsWith("!") && (!result.notes || result.notes.length === 0)) {
								// Create a breaking change note for the ! syntax
								const breakingNote = {
									title: "🚨 Breaking Changes",
									text: `${result.subject} (marked with ! in commit type)`
								};

								// Initialize notes array if it doesn't exist
								if (!result.notes) {
									result.notes = [];
								}

								// Add the breaking note
								result.notes.push(breakingNote);
							}

							return result;
						}
					}
				}
			],
			["@semantic-release/github"]
		],
		repositoryUrl,
		tagFormat: "${version}"
	};
}

function getCIConfig() {
	// contains your normal semantic-release config
	// this will be used on your CI environment
	return {
		branches: ["main", "test-breaking-changes"],
		plugins: [
			[
				"@semantic-release/commit-analyzer",
				{
					preset: "conventionalcommits",
					releaseRules: [
						{ type: "feat", release: "minor" },
						{ type: "fix", release: "patch" },
						{ type: "perf", release: "patch" },
						{ type: "build", release: "patch" },
						{ type: "ci", release: "patch" },
						{ type: "chore", release: "patch" },
						{ type: "docs", release: "patch" },
						{ type: "refactor", release: "patch" },
						{ type: "style", release: "patch" },
						{ type: "test", release: "patch" },
						{ scope: "no-release", release: false },
						{ breaking: true, release: "major" }
					],
					parserOpts: {
						noteKeywords: ["BREAKING CHANGE", "BREAKING CHANGES"],
						headerPattern: /^(\w*)(?:\(([\w\$\.\-\* ]*)\))?(!)?:(.*)$/,
						breakingHeaderPattern: /^(\w*)(?:\(([\w\$\.\-\* ]*)\))?!:(.*)$/
					}
				}
			],
			[
				"@semantic-release/release-notes-generator",
				{
					preset: "conventionalcommits",
					parserOpts: {
						noteKeywords: ["BREAKING CHANGE", "BREAKING CHANGES"],
						issuePrefixes: ["#"]
					},
					writerOpts: {
						// Partial templates
						commitPartial: "- {{#if scope}}**{{scope}}:** {{/if}}{{subject}} ({{hash}})\n",
						notePartial: "- {{text}}\n",

						// Group commits by their type
						groupBy: "type",

						// Sort commits within groups
						commitsSort: ["subject", "scope"],

						// Sort note groups (BREAKING CHANGE should be first)
						noteGroupsSort: (a, b) => {
							// Always put BREAKING CHANGE at the top
							if (a.title.includes("BREAKING CHANGE") || a.title === "🚨 Breaking Changes") return -1;
							if (b.title.includes("BREAKING CHANGE") || b.title === "🚨 Breaking Changes") return 1;

							// Default alphabetical sort for other note types
							return a.title.localeCompare(b.title);
						},

						// Customize the header to include version and date
						headerPartial: "## {{version}} {{#if date}}({{date}}){{/if}}\n\n",

						// Custom main template that puts note groups before commit groups
						mainTemplate:
							"{{> header}}{{#if noteGroups}}{{#each noteGroups}}\n\n### {{title}}\n\n{{#each notes}}* {{text}}\n{{/each}}{{/each}}{{/if}}{{#if commitGroups}}{{#each commitGroups}}\n\n### {{title}}\n\n{{#each commits}}{{> commit root=@root}}{{/each}}{{/each}}{{/if}}\n",

						// Sort sections in a specific order
						commitGroupsSort: (a, b) => {
							// Define section order
							const order = [
								"🚨 Breaking Changes",
								"✨ Features",
								"🐛 Bug Fixes",
								"🧪 Tests",
								"📦 Code Refactoring",
								"⚡ Performance Improvements",
								"💎 Styles",
								"📚 Documentation",
								"⚙️ Continuous Integration",
								"🛠️ Build System",
								"♻️ Chores",
								"🗑 Reverts"
							];
							const indexA = order.indexOf(a.title);
							const indexB = order.indexOf(b.title);

							// Sort based on the order
							if (indexA !== -1 && indexB !== -1) {
								return indexA - indexB;
							}

							// Prioritize sections in the list
							if (indexA !== -1) return -1;
							if (indexB !== -1) return 1;

							// Fallback to alphabetical sort
							return a.title.localeCompare(b.title);
						},

						// Transform function for commits
						transform: (commit, context) => {
							// Skip certain commits
							if (commit.subject?.toLowerCase().startsWith("initial commit") || !commit.type) {
								return false;
							}

							// Create a new object that will contain all the properties of the original commit
							const result = { ...commit };

							// Ensure shortHash is available for URL links
							if (result.hash) {
								result.shortHash = result.hash.substring(0, 7);
							}

							// Process issue references
							if (typeof result.subject === "string") {
								const issues = [];
								result.subject = result.subject.replace(/#([0-9]+)/g, (_, issue) => {
									issues.push(issue);
									const issueUrl = context.repository
										? `${context.host ?? ""}/${context.owner ?? ""}/${context.repository}`
										: (context.repoUrl ?? "");
									return `[#${issue}](${issueUrl ? `${issueUrl}/issues/${issue}` : `#${issue}`})`;
								});
							}

							// Add emoji based on type
							const types = {
								breaking: "🚨 Breaking Changes",
								feat: "✨ Features",
								fix: "🐛 Bug Fixes",
								docs: "📚 Documentation",
								style: "💎 Styles",
								refactor: "📦 Code Refactoring",
								perf: "⚡ Performance Improvements",
								test: "🧪 Tests",
								build: "🛠️ Build System",
								ci: "⚙️ Continuous Integration",
								chore: "♻️ Chores",
								revert: "🗑 Reverts"
							};

							// Handle types with ! in them
							let typeKey = result.type;
							if (typeKey && typeKey.endsWith("!")) {
								// Remove the ! to match the type in the types object
								typeKey = typeKey.substring(0, typeKey.length - 1);
							}

							// Override type with emoji version
							if (typeKey && types[typeKey]) {
								result.type = types[typeKey];
							}

							// Handle BREAKING CHANGE notes
							if (result.notes) {
								// Create a new array with modified note objects
								result.notes = result.notes.map((note) => {
									// Clone the note object
									const modifiedNote = { ...note };
									// Rename the title from "BREAKING CHANGE" to "🚨 Breaking Changes"
									if (
										modifiedNote.title === "BREAKING CHANGE" ||
										modifiedNote.title === "BREAKING CHANGES"
									) {
										modifiedNote.title = "🚨 Breaking Changes";
									}
									return modifiedNote;
								});
							}

							// Handle the feat! syntax - create a breaking change note if there isn't one already
							if (commit.type && commit.type.endsWith("!") && (!result.notes || result.notes.length === 0)) {
								// Create a breaking change note for the ! syntax
								const breakingNote = {
									title: "🚨 Breaking Changes",
									text: `${result.subject} (marked with ! in commit type)`
								};

								// Initialize notes array if it doesn't exist
								if (!result.notes) {
									result.notes = [];
								}

								// Add the breaking note
								result.notes.push(breakingNote);
							}

							return result;
						}
					}
				}
			],
			[
				"@semantic-release/npm",
				{
					npmPublish: false
				}
			],
			[
				"@semantic-release/git",
				{
					assets: ["package.json", "pnpm-lock.yaml"],
					message: "release: ${nextRelease.version}"
				}
			],
			[
				"@semantic-release/github",
				{
					addReleases: "bottom",
					failComment: false,
					failTitle: false,
					labels: ["release"],
					releasedLabels: ["released"],
					successComment:
						"This ${issue.pull_request ? 'PR is included' : 'issue has been resolved'} in version ${nextRelease.version}",
					// Custom release title template with version only
					releaseNameTemplate: "v${nextRelease.version}",
					// Custom release body template using the same format as our CHANGELOG
					releaseBodyTemplate: `<% 
							  // Remove the first two lines (version header and empty line)
							const modifiedNotes = nextRelease.notes.split('\\n').slice(2).join('\\n');
						%><%= modifiedNotes %>`,
					assets: [
						{
							path: "src/zsh-nvm-pnpm-auto-switch.plugin.zsh",
							name: "zsh-nvm-pnpm-auto-switch.plugin.zsh"
						},
						{
							path: "src/workspace-config.zsh",
							name: "workspace-config.zsh"
						},
						{
							path: "src/install-remote.sh",
							name: "install-remote.sh"
						},
						{
							path: "src/install.sh",
							name: "install.sh"
						},
						{
							path: "src/debug.sh",
							name: "debug.sh"
						}
					]
				}
			]
		],
		repositoryUrl,
		tagFormat: "${version}"
	};
}

function isDryRun() {
	console.log("process.argv", process.argv);
	return process.argv.includes("--dry-run");
}

function getLocalRepoUrl() {
	const topLevelDir = execSync("git rev-parse --show-toplevel").toString().trim();

	return `file://${topLevelDir}/.git`;
}

function getCurrentBranch() {
	const branch = execSync("git rev-parse --abbrev-ref HEAD").toString().trim();
	console.log("branch", branch);
	return branch;
}

/**
 * @type {import('semantic-release').GlobalConfig}
 */
export default isDryRun() ? getDryRunConfig() : getCIConfig();
