import { validateEnv } from "@/lib/validators";

/**
 * Validated environment configuration
 * Access environment variables through this module
 * 
 * Note: In production, ensure all required env vars are set
 * This will throw an error if validation fails
 */
let env: ReturnType<typeof validateEnv>;

try {
  env = validateEnv();
} catch (error) {
  // In development, provide defaults
  if (process.env.NODE_ENV === "development") {
    env = {
      NODE_ENV: "development",
      NEXT_PUBLIC_API_URL: undefined,
    };
  } else {
    throw error;
  }
}

export { env };

