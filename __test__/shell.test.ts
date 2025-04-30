import { execSync } from "child_process";
import { existsSync } from "fs";
import path from "path";
import { glob } from "glob";
import { shellcheck } from "shellcheck";
import { describe, it, expect } from "vitest";

interface ShellCheckIssue {
	line: number;
	column: number;
	message: string;
	code: number;
}

describe("shell scripts validation", () => {
	it("bash scripts should have valid syntax", () => {
		const shellScripts = execSync('find . -name "*.sh"').toString().trim().split("\n").filter(Boolean);
		expect(shellScripts.length).toBeGreaterThan(0);

		for (const script of shellScripts) {
			try {
				execSync(`bash -n ${script}`);
			} catch (error) {
				throw new Error(`Bash syntax error in ${script}: ${String(error)}`);
			}
		}
	});

	it("zsh scripts should have valid syntax", () => {
		// Skip if not running on CI environment where zsh might not be available
		if (process.env.CI !== "true" && !execSync("which zsh || echo not-found").toString().includes("zsh")) {
			console.warn("Skipping zsh syntax check as zsh is not installed");
			return;
		}

		const zshScripts = execSync('find . -name "*.zsh" -o -name "*.plugin.zsh"').toString().trim().split("\n");
		if (zshScripts.length === 0 || (zshScripts.length === 1 && zshScripts[0] === "")) {
			console.log("No zsh scripts found");
			return;
		}

		for (const script of zshScripts) {
			if (!script.trim()) continue;
			try {
				execSync(`zsh -n ${script}`);
			} catch (error) {
				throw new Error(`Zsh syntax error in ${script}: ${String(error)}`);
			}
		}
	});

	it("all shell scripts should be analyzed with shellcheck", async () => {
		const shellScripts = await glob("src/*.sh");
		expect(shellScripts.length).toBeGreaterThan(0);

		const scriptResults: { script: string; output: string }[] = [];

		for (const script of shellScripts) {
			const result = await shellcheck({
				args: [script, "--format=json"]
			});

			// Log ShellCheck results for debugging
			if (result.status !== 0) {
				let output = "";

				// Try to parse JSON output if available
				try {
					// If we have stdout data, try to parse it as JSON
					if (result.stdout instanceof Buffer && result.stdout.length > 0) {
						const jsonOutput = JSON.parse(result.stdout.toString("utf8")) as ShellCheckIssue[];

						// Format the output from the parsed JSON data
						if (jsonOutput.length > 0) {
							output = jsonOutput
								.map(
									(issue: ShellCheckIssue) =>
										`Line ${String(issue.line)}, Col ${String(issue.column)}: ${issue.message} [SC${String(issue.code)}]`
								)
								.join("\n");
						}
					}
					// If we don't have valid JSON output but have stderr data, use that
					else if (result.stderr instanceof Buffer && result.stderr.length > 0) {
						output = result.stderr.toString("utf8");
					}
				} catch (_error) {
					// If JSON parsing fails, fall back to stderr if available
					if (result.stderr instanceof Buffer && result.stderr.length > 0) {
						output = result.stderr.toString("utf8");
					} else {
						output = "Unknown error";
					}
				}

				scriptResults.push({
					script,
					output
				});
			}
		}

		// If there are any shellcheck issues, log them and fail the test
		if (scriptResults.length > 0) {
			let errorMessage = "\nShellCheck found issues in the following files:\n";

			scriptResults.forEach(({ script, output }) => {
				errorMessage += `\n${script}:\n`;
				errorMessage += output || "Unknown issues detected";
				errorMessage += "\n";
			});

			errorMessage += "\nPlease fix these issues before proceeding.";

			// Fail the test with the detailed error message
			throw new Error(errorMessage);
		}
	});

	it("debug.sh script exists and is executable", () => {
		const debugScriptPath = path.resolve("src/debug.sh");
		expect(existsSync(debugScriptPath)).toBe(true);

		const stats = execSync(`ls -la ${debugScriptPath}`).toString();
		expect(stats).toContain("x"); // Check for executable flag
	});

	it("install.sh script exists and is executable", () => {
		const installScriptPath = path.resolve("src/install.sh");
		expect(existsSync(installScriptPath)).toBe(true);

		const stats = execSync(`ls -la ${installScriptPath}`).toString();
		expect(stats).toContain("x"); // Check for executable flag
	});

	it("install-remote.sh script exists and is executable", () => {
		const installRemoteScriptPath = path.resolve("src/install-remote.sh");
		expect(existsSync(installRemoteScriptPath)).toBe(true);

		const stats = execSync(`ls -la ${installRemoteScriptPath}`).toString();
		expect(stats).toContain("x"); // Check for executable flag
	});
});
