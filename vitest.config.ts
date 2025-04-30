import { defineConfig } from "vitest/config";

export default defineConfig({
	test: {
		globals: false,
		environment: "node",
		include: ["__test__/**/*.test.ts"],
		coverage: {
			reporter: ["text", "json", "html"]
		}
	}
});
