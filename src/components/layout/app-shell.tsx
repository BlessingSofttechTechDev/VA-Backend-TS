"use client";

import React, { type ReactNode } from "react";
import { Navbar } from "./navbar";
import { Footer } from "./footer";
import { cn } from "@/lib/utils";

interface AppShellProps {
  children: ReactNode;
  className?: string;
}

/**
 * Main application shell component
 * Wraps the application with consistent layout structure
 */
export function AppShell({ children, className }: AppShellProps): React.ReactElement {
  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />
      <main className={cn("flex-1", className)}>{children}</main>
      <Footer />
    </div>
  );
}

