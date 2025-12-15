/**
 * Global TypeScript type definitions
 * Centralized type exports for the application
 */

// API Response types
export interface ApiResponse<T = unknown> {
  data: T;
  message?: string;
  success: boolean;
}

export interface ApiError {
  message: string;
  code?: string;
  details?: unknown;
}

// Add more global types as needed

