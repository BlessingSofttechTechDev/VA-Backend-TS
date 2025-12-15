import { z } from "zod";

/**
 * Environment variables validation schema
 * Ensures all required environment variables are present and valid
 */
export const envSchema = z.object({
  NODE_ENV: z
    .enum(["development", "production", "test"])
    .default("development"),
  NEXT_PUBLIC_API_URL: z
    .string()
    .url()
    .optional()
    .or(z.literal("").transform(() => undefined)),
  DATABASE_URL: z
    .string()
    .min(1, "DATABASE_URL is required")
    .describe(
      "PostgreSQL connection string used by backend tooling and migrations"
    ),
  EXOTEL_API_KEY: z.string().optional(),
  EXOTEL_API_TOKEN: z.string().optional(),
  EXOTEL_ACCOUNT_SID: z.string().optional(),
});

export type Env = z.infer<typeof envSchema>;

/**
 * Validates and returns environment variables
 * Throws error if validation fails
 */
export function validateEnv(): Env {
  try {
    return envSchema.parse({
      NODE_ENV: process.env.NODE_ENV,
      NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
      DATABASE_URL: process.env.DATABASE_URL,
      EXOTEL_API_KEY: process.env.EXOTEL_API_KEY,
      EXOTEL_API_TOKEN: process.env.EXOTEL_API_TOKEN,
      EXOTEL_ACCOUNT_SID: process.env.EXOTEL_ACCOUNT_SID,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new Error(`Invalid environment variables: ${error.message}`);
    }
    throw error;
  }
}
