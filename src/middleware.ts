import { type NextRequest, NextResponse } from "next/server";

/**
 * Next.js middleware
 * Handles request/response processing, authentication, redirects, etc.
 */
export function middleware(_request: NextRequest): NextResponse {
  // Add middleware logic here (auth, redirects, headers, etc.)
  const response = NextResponse.next();

  // Example: Add security headers
  response.headers.set("X-Content-Type-Options", "nosniff");
  response.headers.set("X-Frame-Options", "DENY");
  response.headers.set("X-XSS-Protection", "1; mode=block");

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    "/((?!api|_next/static|_next/image|favicon.ico).*)",
  ],
};

