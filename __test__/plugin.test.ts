import { readFileSync, existsSync } from "fs";
import path from "path";
import { describe, it, expect } from "vitest";

describe("zsh plugin functionality", () => {
	it("plugin file exists and contains auto-switch functionality", () => {
		const pluginPath = path.resolve("src/zsh-nvm-pnpm-auto-switch.plugin.zsh");
		expect(existsSync(pluginPath)).toBe(true);

		const content = readFileSync(pluginPath, "utf8");

		// Check for essential functions/features
		expect(content).toContain("autoload"); // Should use autoload
		expect(content).toContain("()"); // Should define functions using ZSH syntax
		expect(content).toContain("nvm"); // Should reference nvm
		expect(content).toContain("pnpm"); // Should reference pnpm
		expect(content).toContain("chpwd"); // Should use directory change hook
	});

	it("workspace-config.zsh file exists", () => {
		const configPath = path.resolve("src/workspace-config.zsh");
		expect(existsSync(configPath)).toBe(true);

		const content = readFileSync(configPath, "utf8");
		expect(content.length).toBeGreaterThan(0);
	});

	// Test for expected environment detection
	it("plugin can detect NodeJS environments", () => {
		const pluginPath = path.resolve("src/zsh-nvm-pnpm-auto-switch.plugin.zsh");
		const content = readFileSync(pluginPath, "utf8");

		// Check for .nvmrc detection
		expect(content).toContain(".nvmrc");

		// Check for package.json detection
		expect(content).toContain("package.json");
	});
});
