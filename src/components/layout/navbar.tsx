"use client";

import React from "react";
import { cn } from "@/lib/utils";

interface NavbarProps {
  className?: string;
}

/**
 * Main navigation bar component
 * Professional, scalable navbar for the application
 */
export function Navbar({ className }: NavbarProps): React.ReactElement {
  return (
    <nav
      className={cn(
        "border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60",
        className
      )}
    >
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <div className="flex items-center gap-2">
          <h1 className="text-xl font-semibold">VA Backend</h1>
        </div>
        <div className="flex items-center gap-4">
          {/* Navigation items will go here */}
        </div>
      </div>
    </nav>
  );
}

