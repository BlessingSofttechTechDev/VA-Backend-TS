"use client";

import React from "react";
import { cn } from "@/lib/utils";

interface FooterProps {
  className?: string;
}

/**
 * Footer component
 * Professional footer for the application
 */
export function Footer({ className }: FooterProps): React.ReactElement {
  return (
    <footer
      className={cn(
        "border-t border-border bg-background",
        className
      )}
    >
      <div className="container mx-auto px-4 py-8">
        <div className="flex flex-col items-center justify-center gap-4 text-center text-sm text-muted-foreground">
          <p>© {new Date().getFullYear()} VA Backend. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}

