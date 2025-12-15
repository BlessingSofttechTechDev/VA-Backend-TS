import axios, { type AxiosInstance, type AxiosRequestConfig } from "axios";

/**
 * Base API client configuration
 * Centralized axios instance for all API calls
 */
const createApiClient = (baseURL?: string): AxiosInstance => {
  const config: AxiosRequestConfig = {
    baseURL: baseURL || process.env.NEXT_PUBLIC_API_URL || "/api",
    timeout: 30000,
    headers: {
      "Content-Type": "application/json",
    },
  };

  const client = axios.create(config);

  // Request interceptor
  client.interceptors.request.use(
    (config) => {
      // Add auth tokens, logging, etc. here
      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );

  // Response interceptor
  client.interceptors.response.use(
    (response) => response,
    (error) => {
      // Handle global error responses
      return Promise.reject(error);
    }
  );

  return client;
};

export const apiClient = createApiClient();

