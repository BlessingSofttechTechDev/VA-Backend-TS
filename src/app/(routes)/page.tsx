import React from "react";
import { AppShell } from "@/components/layout";
import { Button } from "@/components/ui/button";

/**
 * Homepage component
 * Clean, professional landing page demonstrating the architecture
 */
export default function HomePage(): React.ReactElement {
  return (
    <AppShell>
      <div className="container mx-auto flex min-h-[calc(100vh-8rem)] flex-col items-center justify-center px-4 py-16">
        <div className="flex max-w-2xl flex-col items-center gap-8 text-center">
          <h1 className="text-5xl font-bold tracking-tight sm:text-6xl">
            Hello World
          </h1>
          <p className="text-lg text-muted-foreground sm:text-xl">
            Production-ready Next.js boilerplate initialized.
          </p>
          <div className="mt-8 flex flex-col gap-4 sm:flex-row">
            <Button asChild>
              <a href="/api/health">Check API Health</a>
            </Button>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
